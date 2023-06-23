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
  group_by(year(date)) |>
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
      vehicle_color == "DBL" ~ "Blue", # Guessing a bit here -- should this be separate from "Blue"?
      vehicle_color == "LBL" ~ "Blue", # Same as above,
      vehicle_color == "LGR" ~ "Gray",
      vehicle_color == "DGR" ~ "Gray",
      vehicle_color == "TEA" ~ "Teal",
      vehicle_color == "CRM" ~ "Cream",
      vehicle_color == "PNK" ~ "Pink",
      vehicle_color == "PLE" ~ "Unknown / Other", # I don't know what "PLE" means! Purple maybe?
      grepl("\\|", vehicle_color) ~ "Unknown / Other", # A few have multiple listed; gonna classify as "Unknown / Other" for now.
      # TRUE ~ vehicle_color
      TRUE ~ "Unknown / Other"
    )
  )

# The ones with multiple colors listed -- gonna file them as "Unknown / Other"
okc_data_clean |> 
  filter(grepl("\\|", vehicle_color)) |>
  select(vehicle_color)

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
      # TRUE ~ vehicle_make
      TRUE ~ "Unknown / Other"
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
      # TRUE ~ vehicle_model
      TRUE ~ "Unknown / Other"
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

# What would it look like to clean other parts of this data?
summary(okc_data_clean$speed)
summary(okc_data_clean$subject_age)


# Analyzing the cleaned data ===================================================
# Now, we can start to answer our research question! Let's make some graphs! 

# ggplot2 example:
# First we make the graph itself and tell it what data to use...
ggplot(data = okc_data_clean,
       aes(x = subject_age)) +
  # ...then we tell it what to draw with that data
  geom_histogram()

# Bar chart to answer the "vehicle make" part of our research question ---------
okc_data_clean |>
  filter(!is.na(vehicle_make_clean)) |>
  count(vehicle_make_clean) |>
  ggplot(aes(x = vehicle_make_clean,
             y = n)) +
  geom_col() 

# # Not very pretty... let's tidy it up a bit and save it as a new object:
chart_make <- okc_data_clean |>
  filter(!is.na(vehicle_make_clean)) |>
  count(vehicle_make_clean) |>
  ggplot(aes(x = reorder(vehicle_make_clean, n),
             y = n)) +
  coord_flip() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "OKC Traffic Citations by Make of Cited Vehicle",
       subtitle = paste0("All vehicle citations issued ", min(okc_data_clean$year), " through ", max(okc_data_clean$year)),
       caption = "Data from https://openpolicing.stanford.edu/data/") +
  geom_col() +
  ggthemes::theme_fivethirtyeight()

chart_make

# Vehicle color ----------------------------------------------------------------
# We can add custom scales and colors:
color_scale <- c("White" = "white", "Black" = "black",
                 "Silver" = "azure2", "Red" = "red",
                 "Gray" = "darkgray", "Blue" = "blue4",
                 "Unknown / Other" = "gray30", "Maroon" = "red4",
                 "Green" = "seagreen", "Tan" = "papayawhip",
                 "Gold" = "yellow4", "Brown" = "tan4",
                 "Yellow" = "yellow", "Orange" = "orange",
                 "Beige" = "wheat", "Teal" = "turquoise",
                 "Cream" = "seashell", "Pink" = "pink") 

okc_data_clean |>
  group_by(vehicle_color_clean) |>
  summarize(n = n()) |>
  ggplot(aes(x = reorder(vehicle_color_clean, n), # Reorders our columns by `n`
             y = n,
             fill = vehicle_color_clean)) +
  geom_col(color = "black") +
  coord_flip() + # Flips X and Y axes
  # Some nice captions / labels
  labs(title = "OKC Traffic Citations by Color of Cited Vehicle",
       subtitle = paste0("All vehicle citations issued ", min(okc_data_clean$year), " through ", max(okc_data_clean$year)),
       caption = "Data from https://openpolicing.stanford.edu/data/") +
  scale_fill_manual(values = color_scale) +
  scale_y_continuous(labels = scales::comma) +
  guides(fill = "none") +
  ggthemes::theme_fivethirtyeight() # A sweet pre-built theme!

# Vehicle Model, but I'm sick of bar charts ------------------------------------
okc_data_clean |>
  filter(vehicle_model_clean != "Unknown / Other",
         year >= 2012 & year <= 2017) |>
  group_by(vehicle_model_clean,
           month = floor_date(date, "months")) |>
  summarize(n = n()) |>
  ggplot(aes(x = month,
             y = n,
             color = vehicle_model_clean)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 2) +
  labs(title = "OKC Traffic Citations by Vehicle Model Type",
       subtitle = paste0("All vehicle citations issued ", min(okc_data_clean$year), " through ", max(okc_data_clean$year)),
       caption = "Data from https://openpolicing.stanford.edu/data/",
       x = "Year of Citation",
       y = "Total Citations Issued") +
  scale_y_continuous(labels = scales::comma) +
  scale_color_viridis_d("Vehicle Type") +
  ggthemes::theme_gdocs()

# Answering our research question ==============================================

# Looking at only data with complete make, model, color info:
okc_data_clean |>
  filter(!is.na(vehicle_model), !is.na(vehicle_make), !is.na(vehicle_color)) |>
  mutate(
    vehicle_color_make_model = paste(vehicle_color_clean, vehicle_make_clean, vehicle_model_clean)
  ) |>
  count(vehicle_color_make_model, sort = TRUE) |>
  print(n = 10)

# Looking without model:
okc_data_clean |>
  mutate(
    vehicle_color_make_model = paste(vehicle_color_clean, vehicle_make_clean)
  ) |>
  count(vehicle_color_make_model, sort = TRUE) |>
  print(n = 10)

# The answer: it depends on how you look at it! But maybe keep an eye on black / white pickup trucks from Chevy / Ford

# Where can we go from here?
# - This doesn't tell us much about the behavior of each car types' drivers. Can we make these numbers per capita?
# - Can we apply this same code / approach to a national dataset?
# - Can we look closer at geography? Maybe its relation to race, vehicle type, etc.?


# Other cool charts you can make -----------------------------------------------

# Facets make it easy to break out graphs with extra variables  ----
# We can swap `subject_sex` with `subject_race` here and get the same graph 
okc_data_clean |>
  filter(!is.na(subject_sex)) |>
  group_by(vehicle_color_clean, subject_sex) |>
  summarize(n = n()) |>
  ggplot(aes(x = tidytext::reorder_within(vehicle_color_clean, n, subject_sex),
             y = n,
             fill = vehicle_color_clean)) +
  geom_col(color = "black") +
  coord_flip() + 
  labs(title = "OKC Traffic Citations by Color of Cited Vehicle",
       subtitle = paste0("All vehicle citations issued ", min(okc_data_clean$year), " through ", max(okc_data_clean$year)),
       caption = "Data from https://openpolicing.stanford.edu/data/") +
  scale_fill_manual(values = color_scale) +
  scale_y_continuous(labels = scales::comma) +
  tidytext::scale_x_reordered() +
  guides(fill = "none") +
  facet_wrap(~subject_sex, scales = "free") +
  ggthemes::theme_fivethirtyeight()

# Interactive graphs ----
library(plotly)

ggplotly(chart_make, tooltip = "y")

# Maps ----
library(sf)
library(ggspatial)
library(tidycensus)
library(tigris)

okc_shape <- zctas(state = "Oklahoma", year = 2010)
uas <- urban_areas()
okc_ua <- uas[grep("Oklahoma City", uas$NAME10), ]
okc_shape <- okc_shape[okc_ua, ]
okc_shape <- okc_shape |>
  select(zip = GEOID10) |>
  st_transform(4326) 

sf_okc_citation_locations <- okc_data_clean |>
  filter(!is.na(lng), !is.na(lat)) |>
  st_as_sf(coords = c("lng", "lat"), remove = FALSE) |>
  mutate(year = year(date)) |>
  st_set_crs(st_crs(okc_shape))

sample <- sf_okc_citation_locations |>
  slice_sample(prop = 0.1)

ggplot(okc_shape) +
  annotation_map_tile(zoomin = 2) +
  stat_density_2d_filled(data = sample,
                         aes(x = lng, 
                             y = lat,
                             alpha = after_stat(level)),
                         contour_var = "count",
                         show.legend = FALSE) +
  geom_point(data = sample,
             aes(x = lng, y = lat),
             shape = 1,
             size = 0.5,
             alpha = 0.1,
             color = "black") +
  geom_sf(alpha = 0,
          size = 0) +
  lims(x = c(-97.75, -97.35),
       y = c(35.32, 35.6)) +
  scale_fill_viridis_d(option = "turbo") +
  scale_alpha_manual(values = c(0, rep(0.5, 13))) +
  guides(alpha = "none") +
  ggthemes::theme_map()


