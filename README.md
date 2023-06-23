# SPI Session 1: OKC (June 29-30, 2023)

> For the OKC SPI session, Research Team will be presenting a start-to-finish guide on the entire process of taking a research question and turning it into data-based visualizations and analyses, using Oklahoma City traffic citation data as a case study. We will cover how to search for public data, both in the criminal justice space and in others, as well as the basics of how to analyze that data in R, including turning it charts, tables, and maps. By the end, attendees will have a list of useful data sources and knowledge on how to find new ones, a basic understanding of how to make use of them using R or Excel, and the answer to our research question -- "in Oklahoma City, what color and type of car gets ticketed the most?"

## Presentation Outline:

1) Where do you get data from?
2) How and why do you get data into R / RStudio?
3) How and why do you "clean" data with R?
4) How do you analyze / graph data with R?
5) What other cools stuff is possible with R?

## Our Research Question

We're going to see if we can find data to shed light on the following research question: "In Oklahoma City, what **color** and **type** of car gets ticketed the most?"

To answer this, we'll need to find some good quality data on traffic citation issuances in Oklahoma City. Ideally, we'd like the data to cover multiple years, and we'll need to be able to see details like the vehicle's make, model, color, etc. If we want to look at more serious aspects of traffic stops, we should also look for data that includes informaiton on the driver, such as their race, gender, age, etc.

## 1. Finding Data Sources

We're going to start from absolutely nothing and simply fire up our favorite search engine. We'll vary our search terms (e.g. "traffic citation" vs. "traffic stop") and include some modifiers like "dataset", "GitHub", etc. and see what we can come up with. We'll steer clear of ad-ridden, low-quality, "anyone can upload" sites like Kaggle, Data.World, etc.

After some searching, there seem to be a few datasets that fit what we're looking for:

- Our main dataset: [Stanford Open Policing: OKC traffic citations from Dec 2010 - Nov 2020](https://openpolicing.stanford.edu/data/)
  - Details on how this data was collected, etc. are found on [their GitHub](https://github.com/stanford-policylab/opp/blob/master/data_readme.md)
- Other examples of potentially good traffic stop data sources:
  - Vermont state government publishes their stats [here](https://vsp.vermont.gov/communityaffairs/trafficstops)
  - St. Paul Minnesota publishes theirs [here](https://information.stpaul.gov/datasets/stpaul::traffic-stops/explore)

Sometimes you can't find anything just searching around. In those scenarios, you might have to look for alternatives:
- Sometimes you can just reach out to the people who should have the data (government agencies in particular). I recently did this with the Oklahoma State Bureau of Investigation, and they very helpfully gave me a nice spreadsheet of exactly what I was looking for.
- Sometimes you can't find a nice dataset to download, but you can find an API (Application Programming Interface) or database to query. This is a little more technologically involved, however. The easiest way to do this, generally, is to find an R or Python package (like [{tidycensus}](https://cran.r-project.org/web/packages/tidycensus/index.html) for US Census data, for example) that lets you access the data using simplififed R commands.

A collection of other helpful data sources for public policy research:
- [Federal Election Commission -- federal campaign finance contributions](https://www.fec.gov/data/elections/president/2024/)
- [The Oklahoma Ethics Commission's "Guardian System" -- state level campaign finance contributions](https://guardian.ok.gov/PublicSite/HomePage.aspx)
- [US Census -- tons of data on who lives where and what their lives are like, with a great search interface](https://data.census.gov/)
- 

## 2. Examining our Data: The Wonderful World of R

Our OKC traffic stop data has nearly 1,000,000 rows -- that's great! But if we try to open a dataset that large in a program like Google Sheets, Microsoft Excel, or LibreOffice Calc, our computers are probably going to throw a fit. So we're going to turn to [The R statistical programming language](https://www.r-project.org/about.html). 

If Excel is a Toyota Camry, R is a custom-built Formula 1 car -- both can get you where you need to go most of the time, but R lets us do more, do it faster, and do it with much larger datasets. It's popular with academics and researchers in particular, and it's what Open Justice Oklahoma uses for most of our work. And best of all, it's entirely free and open source! We'll start by getting R all set up on our computers, then we'll open up our dataset and get analyzing.

### Installing R and RStudio

We'll start by making sure the R language is installed on our computers. We'll also install RStudio, and integrated development environment (IDE) made for doing data analysis in R. Here's a good guide on how to install both: https://rstudio-education.github.io/hopr/starting.html

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/c7d85618-28ca-4db0-8356-3929a6e0fc60)

Here's a quick tour:

- On the left, you'll see the R console. You can type R code into it and press enter to execute it. For example, you could try typing in `235 * 293`, and it'll return the answer like a calculator. You could also type something like `235 * 293 > 10`, which would return `TRUE`, since the answer is indeed greater than 10.
- In the upper right portion of RStudio, you'll see your current R enviornment (among other things, which aren't as important right now). If we stored a value as a variable in our R console (for example, by typing `x <- 5` or `x = 5` and hitting enter), it'll show up here. It's also where we'll find information on the data we're about to load up, after we've done so.
- In the bottom right portion, you'll see a few different tabs like "Files", "Plots", etc. You can use it for all sorts of things, but it's not particularly important right now.
- At the top, you'll see various menus like "File", "Edit", "Code", "View", etc. You can use these menus to personalize your setup, among other things -- for instance, try clicking "Tools" > "Global Options" > "Appearance" and changing the theme.

Now that we've got our tools installed and set up, it's time to import our data!

### Opening our data in RStudio

We've downloaded our Stanford Open Policing data, and saved it on our computers. Let's assume it's saved in our "Downloads" folder -- on Mac / Linux, that'll be `~/Dowloads/` and on Windows it'll be `C:\Users\YourUserName\Downloads\`. Depending on which version you downloaded, the file will end with `.csv` or `.rds`. Either one will work with R! For convenience, I'm renaming my file to `stanford-citation-data-okc.rds` -- you can also find the data in this GitHub repo, in the `spi-2023/data/okc/` directory.

Once you have the data and know where it is, we'll open a new script in RStudio (`File` > `New File` > `R Script`). You can think of these as literal scripts -- we're giving line-by-line instructions to R, telling it exactly what we want it to do along the way. At the end, we'll run the whole script together, and it will read in our data, analyze it, and produce our graphs, all with the press of a button. Incredible! It should open as a new pane in RStudio.

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/538825e4-af36-4146-be5f-bf5ced2590cd)

> My RStudio is customized and rearranged slightly, so it might look a bit different than yours.

Save your script wherever you'd like, and then we'll add our first lines of R code! The first step, before we actually read in our data, is to install and load some **packages** that will help make our task easier. Packages are one of the best parts of R -- they're little libraries of code, usually to accomplish a specific task, that very smart people wrote to make our lives easier. Today, we'll need the following packages:

- `{dplyr}` -- this package provides easy and convenient functions for manipulating data. We can use it to filter and sort our data in various ways, add new variables / columns to our data, and much more.
- `{readr}` -- this package includes functions for reading in all sorts of data. It can handle `.csv` files as well as `.rds` files, so it's what we'll use to load up our data into R.
- `{lubridate}` -- this package has several useful functions for working with dates / times, which can be tricky.
- `{ggplot2}` -- this is the premier graphing package in R. We'll be using it to make some fun graphs (and maybe even a map!) using our data.

You can install each of them using the R function `install.packages()`. All R functions use this `word()` format -- the word at the beginning tells R which function we're using, and the parentheses are where we'll put the "arguments" we're supplying to the function. In this case, the only argument we need to provide is to tell it which package we want to install.

In your R console, try typing the following:

`install.packages("dplyr")`

`install.packages("readr")`

`install.packages("lubridate")`

`install.packages("ggplot2")`

You can type them straight into the console and press enter, or you can type them into your script and run the code yourself (using Ctrl+Enter, for example). R will do all the work, so just sit back and watch the paragraphs fly by. Also, all of these packages are a part of the [Tidyverse](https://www.tidyverse.org/), a series of packages that all work together to make data analysis in R easier and more accessible. If we want, we can install all of them (plus a few extras) in one go by typing `install.packages("tidyverse")`.

Once they're installed, we have to tell our script that we're going to use them. At the very top of our script, before anything else, we'll do so using the `library()` function. Type the following into your freshly made R Script (**not the console!**), save it, and then run the code:

```
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
```

Now it's finally time to load up the data. We'll be using either `read_csv()` or `read_rds()`, both of which are functions from the `{readr}` package we loaded in a second ago. We'll also be saving our data in our environment, just like we saved `x <- 5` earlier. Let's call our dataset "okc_data" by adding this to our script:

```
okc_data <- read_rds("~/Downloads/stanford-citation-data-okc.rds")
```

If we run our script now, it'll load up all the needed libraries, then read in our data and save it as `okc_data`. You can see in the environment pane of RStudio that all 945,107 rows of our data have been succesfully loaded in R. You can also click the little arrow next to it to see more information about the columns / variables inside. Let's pause and just explore the data in RStudio for a bit.

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/4655efc8-efd3-49b6-aadc-0f8abaad49a6)

## 2.5 Data Analysis in RStudio -- exploring your data

To start digging into this dataset, let's try to answer the following questions:

- What variables exist in the data?
- How "complete" is the data? What is missing?
- What does the data relevant to our research question (the car's make, model, and color) look like? Is any of it missing?

You can give the data a look by simply clicking on it in the Environment panel, or by running `View(okc_data)` in your R console. 

We can also write some code to give us a more fine-tuned look. Below is some of the R code we'll use to explore our dataset. We'll go through what it does and how it works together:

```
# ==== What variables are there in the data? ====
names(okc_data)

# ==== How "complete" is the data? ====
# This code returns a neat table showing the % of each column that are missing, or "NA"

knitr::kable(colMeans(is.na(okc_data))) 

# As you can see, we can use multiple functions together to create interesting results.
# The "pipe" (`|>` or `%>%`) makes this a bit easier; the code below is equivalent to the code above:

okc_data |>
  is.na() |>
  colMeans() |>
  knitr::kable()

# We want to think of it as a pipeline -- we start with the "raw" data, `okc_data`, and we transform it using functions connected by pipes to create a useful result.

# ==== Is there more / less data in some years than others? ====
# The code below shows how many rows we have per year (using the `date` column).
# First, we take our data and use the |> to feed it into the `group_by()` function.

okc_data |>
  group_by(year = year(date)) |> # We want to group the data by the year of the value in the date column.
  # Now our data are grouped by the year of the citation. Next, we pipe that into another function...
  count() # ...which simply counts the number of rows per group.

# ==== How complete are the variables we're interested in? ====
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

```

Judging by our analysis and the [data guide](https://github.com/stanford-policylab/opp/blob/master/data_readme.md), it seems like we have full data coverage from 2012 to 2016 (we also have no info on make / model / color after 2017). We'll probably want to limit our analysis to those years to be sure we're using the best quality data. 

## Can we answer our research question now?

We have the data now -- can we just count to see which make / model / color is the most common?

```
okc_data |>
  # The `mutate()` function is very common, and lets us add new columns.
  mutate(
    # The easiest way to answer our RQ is to smash make + model together into one variable...
    vehicle_color_make_model = paste(vehicle_color, vehicle_make, vehicle_model)
  ) |>
  # ...then count() to see which is most common in the data
  count(vehicle_color_make_model, sort = TRUE)

```

Unfortunately, like most data in the world of public policy, what remains is still very messy -- too messy to answer our research question without more work. Thus, the next step will be cleaning up the relevant columns. In this case, we'll need to pay special attention to the `vehicle_make`, `vehicle_model`, and `vehicle_color` columns.

## 3. Data Analysis in RStudio -- cleaning your data

Our data cleaning tasks:
- Filter out the data we're not interested in -- in this case, we don't need data from 2018 onward, and we don't need the rows corresponding to pedestrian citations (where `type` is `"pedestrian"`).
- Clean up the `vehicle_make`, `vehicle_model`, and `vehicle_color` columns so that they're consistent and easy to read.

The code below is what we'll use to explore and clean up our data, saving it as a new object named `okc_data_clean`. I know it looks like a lot, but don't worry -- it's not as complicated as it looks, and we'll go through it together step by step.

```
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

```

In addition to filtering the data and adding the `year` variable, all we've really done here is classify the vehicle data into clean groups using the `mutate()` and `case_when()` functions. For example, instead of "TOYA" / "TOYT", it just says "Toyota" now. We've also classified the Ford F-150 as a "Pickup", the Toyta Camry as a "Sedan", etc. We've been able to do this for all of the ~550k citations in our filtered data.

At this point, the relevant columns are cleaned up, and we have a good sense of what data are missing. I think we're finally ready to start answering our research question! Because tables are no fun and I'm sick of looking at them, let's do it by making some graphs instead. We'll use our good friend the `{ggplot2}` package to do so.

## 4. Data Analysis in RStudio -- analyzing and graphing your data

We'll start with a chart to answer the "vehicle make" part of our research question. We can turn our data into a nice graph with just a few commands:

```
okc_data_clean |>
  filter(!is.na(vehicle_make_clean)) |>
  count(vehicle_make_clean) |>
  ggplot(aes(x = vehicle_make_clean,
             y = n)) +
  geom_col() 
```

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/d78d7935-69e4-4cc3-a442-4203d5a12b46)


It's not very pretty, but it tells us what we want to know! We can clearly see that Chevy was the most common maker of the cars cited in our data. We can make this more `a e s t h e t i c` with just a few more commands: 

```
okc_data_clean |>
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
```

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/ec76f972-93da-4be3-b159-2d1d5c2e3031)

Nice! If we wanted to, we could even add the company logos with the `{ggimage}` package.

We'll make two more charts, one for vehicle color and one for vehicle model:

```
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
```

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/cc986338-4075-412e-b9db-37870bd71238)

> Snazzy!

```
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
```

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/f89455f2-6c97-491e-88fe-5ba52744e397)

> Note the missing data in the latter months! We'd probably want to cut it off a bit earlier.

## 5. What else can we do with R?

I've included code in our script (`R/okc-traffic-analysis.R`) that shows how to do a few more complex visualizations with this data. We'll go through them briefly, just to show you how powerful R can be:

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/40b0e3ce-3686-4b01-aad5-2a6e6736a7e5)

> **Faceting:** We can break our graphs down even further, breaking it out into multiple graphs using other variables, like race and gender for example.

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/037ffcaa-da56-4b49-845a-ec4411bfa051)

> **Interactivity:** There are awesome libraries that can turn your static graphs into interactive ones! You can customize them and put them on a website, a Shiny app, etc.

![image](https://github.com/openjusticeok/spi-2023/assets/56839927/096ed864-54cb-49da-b267-6d0313a78f80)

> **Geospatial Maps:** There are very powerful tools for map-making and geographical analysis in R. I used the `{tigris}` package to download shape files and map tiles, all without having to leave RStudio.

---
# SPI Session 2: Tulsa (July 20-21, 2023)
