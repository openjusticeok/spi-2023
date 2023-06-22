#  =============================================================================
# First, load up the needed packages
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)

# Optional: I don't like scientific notation
options(scipen=999)

#  =============================================================================
# Next, load up the data
# We'll use the read_rds function from the {readr} package to load up our data
# You might need to replace the file path with wherever you've stored your data.
okc_data <- read_rds("~/Downloads/stanford-citation-data-okc.rds")

# What variables are there in the data?
names(okc_data)

# Let's look at it in spreadsheet form
View(okc_data)

#  =============================================================================
# How "complete" is the data?
# This code returns a neat table showing the % of each column that are missing, or "NA":
knitr::kable(colMeans(is.na(okc_data)))

# As you can see, we can use multiple functions together to create interesting results
# The "pipe" (`|>` or `%>%`) makes this a bit easier; the code below is equivalent to the code above:
okc_data |>
  is.na() |>
  colMeans() |>
  knitr::kable()

# How complete are the variables we're interested in? 
# The code below shows how many rows we have per year (using the `date` column).
# First, we take our data and use the |> to feed it into the `group_by()` function:
okc_data |>
  group_by(year = year(date)) |> # We want to group the data by the year of the value in the date column.
  # Now our data are grouped by the year of the citation. Next, we feed that into another function...
  count() # ...which simply counts the number of rows per group.

# We can combine the `group_by()`` and `summarize()` functions using pipes to get 
# a better idea of what the variables relevant to our RQ look like. 
okc_data |>
  group_by(year = year(date)) |>
  summarize(
    n_citations = n(),
    percent_missing_color = sum(100 * is.na(vehicle_color)) / n_citations,
    percent_missing_make = sum(100 * is.na(vehicle_make)) / n_citations,
    percent_missing_model = sum(100 * is.na(vehicle_model)) / n_citations
    )

# Looks like we might want to filter our data to exclude years past 2018 -- we don't have data on make / model there!

# ==============================================================================
# Answering our research question -- can we do it already?

okc_data |>
  # The `mutate()` function is very common, and lets us add new columns.
  mutate(
    # The easiest way to answer our RQ is to smash make + model together into one variable...
    vehicle_color_make_model = paste(vehicle_color, vehicle_make, vehicle_model)
  ) |>
  # ...then count() to see which is most common in the data
  count(vehicle_color_make_model, sort = TRUE) |>
  print(n = 30)

# This is a decent start, but the messiness in the data is making it hard to tell.

# ==============================================================================
# Let's clean up our relevant columns a bit.
# First, let's figure out what possible values there are for make, color, and model.
okc_data |> 
  count(vehicle_color) |> 
  arrange(desc(n)) |>
  print(n = 20)

okc_data |> 
  count(vehicle_make) |> 
  arrange(desc(n)) |>
  print(n = 20)

okc_data |>
  count(vehicle_model) |> 
  arrange(desc(n)) |>
  print(n = 20)

# Now we have an idea of what we need to clean up.

# Making a new dataset, okc_data_clean
# Let's start by adding a `year` variable and filtering the data
okc_data_clean <- okc_data |> 
  mutate(
    year = year(date), # Adding our `year` variable from before
  ) |>
  filter(
    year >= 2011 & year <= 2017, # Removing the years with no make / model / color data
    type != "pedestrian"  # Removing pedestrian citations
  )

# or...

okc_data |> 
  mutate(
    year = year(date),
  ) |>
  filter(
    year >= 2011 & year <= 2017, 
    type != "pedestrian"
  ) -> okc_data_clean # This is the same as above

# Next, we'll clean up the `color` column. Ideally we'd use a data dictionary / etc. to do this,
# but since we don't have one, we'll have to use our best guess.
okc_data_clean <- okc_data_clean |> 
  mutate(
    # `case_when()` lets us classify each possible value:
    vehicle_color_clean = case_when(
      vehicle_color == "BLK" ~ "Black", # "when `vehicle_color` is "BLK", change it to "Black"
      vehicle_color == "WHI" | vehicle_color == "WHT" ~ "White", # when `vehicle_color` is "WHI" or "WHT", change it to "White".
      vehicle_color == "SIL" ~ "Silver", # etc.
      vehicle_color == "RED" ~ "Red",
      vehicle_color %in% c("GRY", "GRA") ~ "Gray", # This is another way of checking for multiple matches
      vehicle_color == "BLU" ~ "Blue",
      vehicle_color == "MAR" ~ "Maroon",
      vehicle_color == "GRN" ~ "Green",
      vehicle_color == "TAN" ~ "Tan",
      vehicle_color == "GLD" ~ "Gold",
      vehicle_color == "BRO" ~ "Brown",
      vehicle_color == "YEL" ~ "Yellow",
      vehicle_color %in% c("BEI", "BGE") ~ "Beige", 
      vehicle_color %in% c("ONG", "ORG") ~ "Orange",
      vehicle_color == "DBL" ~ "Dark Blue", # Guessing a bit here -- should this be separate from "Blue"?
      vehicle_color == "LBL" ~ "Light Blue", # Same as above,
      vehicle_color == "LGR" ~ "Light Gray",
      vehicle_color == "DGR" ~ "Dark Gray",
      vehicle_color == "TEA" ~ "Teal",
      vehicle_color == "CRM" ~ "Cream",
      vehicle_color == "PNK" ~ "Pink",
      vehicle_color == "PLE" ~ "Unknown / Other", # I don't know what "PLE" means! Purple maybe?
      grepl("\\|", vehicle_color) ~ "Unknown / Other", # A few have multiple listed; gonna classify as "Unknown / Other" for now.
      TRUE ~ vehicle_color
    )
  )

# That column looks a lot better now!
okc_data_clean |> 
  count(vehicle_color_clean) |> 
  arrange(desc(n)) |>
  print(n = 20)

# Let's clean up the `vehicle_make` and `vehicle_model` columns next.
# This time we'll just modify our existing dataset, so we can keep our new columns / avoid having to re-filter
okc_data_clean <- okc_data_clean |> 
  mutate(
    vehicle_make_clean = case_when(
      vehicle_make == "CHEV" ~ "Chevy", # Same basic idea as before. We'll cover the top 25 or so most common ones.
      vehicle_make == "FORD" ~ "Ford",
      vehicle_make == "HOND" ~ "Honda",
      vehicle_make == "DODG" ~ "Dodge",
      vehicle_make == "NISS" ~ "Nissan",
      vehicle_make %in% c("TOYO", "TOYT") ~ "Toyota",
      vehicle_make == "GMC" ~ "GMC",
      vehicle_make == "HYUN" ~ "Hyundai",
      vehicle_make == "JEEP" ~ "Jeep",
      vehicle_make == "PONT" ~ "Pontiac",
      vehicle_make == "CHRY" ~ "Chrysler",
      vehicle_make == "KIA" ~ "Kia",
      vehicle_make == "CADI" ~ "Cadillac",
      vehicle_make == "MAZD" ~ "Mazda",
      vehicle_make == "BUIC" ~ "Buick",
      vehicle_make == "BMW" ~ "BMW",
      vehicle_make %in% c("LEXU", "LEXS") ~ "Lexus",
      vehicle_make == "VOLV" ~ "Volvo",
      vehicle_make %in% c("MERC", "MERB") ~ "Mercedes",
      vehicle_make == "MITS" ~ "Mitsubishi",
      vehicle_make == "VOLK" ~ "Volkswagen",
      vehicle_make == "LINC" ~ "Lincoln",
      vehicle_make == "INFI" ~ "Infiniti",
      vehicle_make == "ACUR" ~ "Acura",
      TRUE ~ vehicle_make
      # TRUE ~ "Unknown / Other"
    ),
    # For the vehicle model, I'm going to clean it up into broader groups like "Pickup", "Sedan", etc.
    # If we want to look at specific models later, we can just use the original variable
    vehicle_model_clean = case_when(
      vehicle_model %in% c("F15", "F25", "F35", "P/U", "SIL", "RAM", "SIE", "RAN", "15H", "S10", "DAK") ~ "Pickup",
      vehicle_model %in% c("ACC", "CIV", "ALT", "MAL", "SEN", "TAU", "CMR", "COR",
                           "300", "JET", "CAV", "TC", "SON", "GAM", "MC", "CV", 
                           "NEO", "REG", "FUS", "200", "FOC", "FOCU", "LB") ~ "Sedan",
      vehicle_model %in% c("EXP", "TAH", "YUK", "CHK", "SUB", "CRV", "ESC", "4RN", "BZR", "WRN", "ECL") ~ "SUV",
      vehicle_model %in% c("MUS", "IPL", "MAX", "IMP", "CHG", "CHA", "GPX", "CEL", "SEB") ~ "Sports Car",
      vehicle_model %in% c("CAR") ~ "Van / Minivan",
      # Specific cases
      vehicle_model == "TAC" & vehicle_make_clean == "Toyota" ~ "Pickup", # Tacoma
      vehicle_model == "TAC" & vehicle_make_clean == "Chrysler" ~ "Van / Minivan", # Town and Country
      vehicle_model == "CAM" & vehicle_make_clean == "Chevy" ~ "Sports Car", # Camero
      vehicle_model == "CAM" & vehicle_make_clean == "Toyota" ~ "Sedan", # Camry
      vehicle_model == "AVA" & vehicle_make_clean == "Chevy" ~ "Pickup", # Avalanche
      vehicle_model == "AVA" & vehicle_make_clean == "Toyota" ~ "Sedan", # Avalon
      vehicle_model == "350" & vehicle_make_clean == "Lexus" ~ "SUV", # Lexus 350
      vehicle_model == "350" & vehicle_make_clean == "Mercedes" ~ "Sports Car", # Mercedes 350
      vehicle_model == "350" & vehicle_make_clean == "Ford" ~ "Pickup", # F-350
      vehicle_model == "350" & vehicle_make_clean == "Nissan" ~ "Sports Car", # Nissan 350
      TRUE ~ vehicle_model
    )
  )
    
# These columns also looks a lot better now!
okc_data_clean |> 
  count(vehicle_make_clean) |> 
  arrange(desc(n)) |>
  print(n = 20)

okc_data_clean |> 
  count(vehicle_model_clean) |> 
  arrange(desc(n)) |>
  print(n = 20)

# Analyzing the cleaned data ===================================================
# Now, we can start to answer our research question! Let's break it down into parts. 
# RQ 1: "What COLOR of car gets ticketed the most?"
  
