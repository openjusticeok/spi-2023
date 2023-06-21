# SPI Session 1: OKC (June 29-30, 2023)

> For the OKC SPI session, Research Team will be presenting a start-to-finish guide on the entire process of taking a research question and turning it into data-based visualizations and analyses, using Oklahoma City traffic citation data as a case study. We will cover how to search for public data, both in the criminal justice space and in others, as well as the basics of how to analyze that data in R, including turning it charts, tables, and maps. By the end, attendees will have a list of useful data sources and knowledge on how to find new ones, a basic understanding of how to make use of them using R or Excel, and the answer to our research question -- "in Oklahoma City, what color and type of car gets ticketed the most?"

## Our Research Question

We're going to see if we can find data to shed light on the following research question: "In Oklahoma City, what **color** and **type** of car gets ticketed the most?"

To answer this, we'll need to find some good quality data on traffic citation issuances in Oklahoma City. Ideally, we'd like the data to cover multiple years, and we'll need to be able to see details like the vehicle's make, model, color, etc. If we want to look at more serious aspects of traffic stops, we should also look for data that includes informaiton on the driver, such as their race, gender, age, etc.

## Finding Data Sources

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

## Examining our Data: The Wonderful World of R

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

## Data Analysis in RStudio

To start digging into this dataset, let's try to answer the following questions:

- What variables exist in the data?
- How "complete" is the data? What is missing?
- What does the data relevant to our research question (the car's make, model, and color) look like? Is any of it missing?

You can give the data a look by simply clicking on it in the Environment panel, or by running `View(okc_data)` in your R console. 

We can also write some code to give us a more fine-tuned look. Below is some of the R code we'll use to explore our dataset. We'll go through what it does and how it works together:

```
# What variables are there in the data?
names(okc_data)

# ==== How "complete" is the data? ==================================================
# This code returns a neat table showing the % of each column that are missing, or "NA"
knitr::kable(colMeans(is.na(okc_data)) * 100) 

# As you can see, we can use multiple functions together to create interesting results
# The "pipe" (`|>` or `%>%`) makes this a bit easier

# This code shows how many rows we have per year (using the `date` column)
# First, we take our data and use the |> to feed it into the `group_by()` function. 
# We'll specify that we want to group the data by the year of the value in the date column.
okc_data |>
  group_by(year = year(date)) |>
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

```

Judging by our analysis and the [data guide](https://github.com/stanford-policylab/opp/blob/master/data_readme.md), it seems like we have full data coverage from 2012 to 2016 (we also have no info on make / model / color after 2017). We'll probably want to limit our analysis to those years to be sure we're using the best quality data. 

Unfortunately, like most data in the world of public policy, what remains is still very messy -- too messy to answer our research question without more work. Thus, the next step will be cleaning up the relevant columns. In this case, we'll need to pay special attention to the `vehicle_make`, `vehicle_model`, and `vehicle_color` columns.

Our data cleaning tasks:
- Clean up the `vehicle_make`, `vehicle_model`, and `vehicle_color` columns so that they're consistent and easy to read.
- Filter out the data we're not interested in -- in this case, we don't need data from 2018 onward, and we don't need the rows corresponding to pedestrian citations (where `type` is `"pedestrian"`).

The code below is what we'll use to explore and clean up our data, saving it as a new object named `okc_data_clean`. I know it looks like a lot, but don't worry -- it's not as complicated as it looks, and we'll go through it together step by step.

```
okc_data_clean <- okc_data |>
  filter(
    year >= 2011 & year <= 2017, # removing the years with no make / model / color data
    type != "pedestrian"
  ) |> # removing pedestrian citations
  mutate(
    year = year(date),
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
      vehicle_color == "PLE" ~ "Unknown / Other", # I don't know what "PLE" means! Purple maybe?
      vehicle_color %in% c("BEI", "BGE") ~ "Beige", 
      vehicle_color %in% c("ONG", "ORG") ~ "Orange",
      vehicle_color == "DBL" ~ "Dark Blue", # Guessing a bit here -- should this be separate from "Blue"?
      vehicle_color == "LBL" ~ "Light Blue", # Same as above,
      vehicle_color == "LGR" ~ "Light Gray",
      vehicle_color == "DGR" ~ "Dark Gray",
      vehicle_color == "TEA" ~ "Teal",
      vehicle_color == "CRM" ~ "Cream",
      vehicle_color == "PNK" ~ "Pink",
      grepl("\\|", vehicle_color) ~ "Unknown / Other", # A few have multiple listed; gonna classify as "Unknown / Other" for now.
      # TRUE ~ vehicle_color
      TRUE ~ "Unknown / Other" # Everything else will be "Unknown / Other"
    ),
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
```

All we've really done here is classify the vehicle data in each citation into clean groups. For example, instead of "TOYA" / "TOYT", it just says "Toyota" now. We've also classified the Ford F-150 as a "Pickup", the Toyta Camry as a "Sedan", etc. We've been able to do this for the vast majority of our ~550k citations in our data from 2011 through 2017, all using the `mutate()` and `case_when()` functions.


---
# SPI Session 2: Tulsa (July 20-21, 2023)
