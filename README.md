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

Here's a quick tour:

- On the left, you'll see the R console. You can type R code into it and press enter to execute it. For example, you could try typing in `235 * 293`, and it'll return the answer like a calculator. You could also type something like `235 * 293 > 10`, which would return `TRUE`, since the answer is indeed greater than 10.
- In the upper right portion of RStudio, you'll see your current R enviornment (among other things, which aren't as important right now). If we stored a value as a variable in our R console (for example, by typing `x <- 5` or `x = 5` and hitting enter), it'll show up here. It's also where we'll find information on the data we're about to load up, after we've done so.
- In the bottom right portion, you'll see a few different tabs like "Files", "Plots", etc. You can use it for all sorts of things, but it's not particularly important right now.
- At the top, you'll see various menus like "File", "Edit", "Code", "View", etc. You can use these menus to personalize your setup, among other things -- for instance, try clicking "Tools" > "Global Options" > "Appearance" and changing the theme.

Now that we've got our tools installed and set up, it's time to import our data!

### Opening our data in RStudio

We've downloaded our Stanford Open Policing data, and saved it on our computers. Let's assume it's saved in our "Downloads" folder -- on Mac / Linux, that'll be `~/Dowloads/` and on Windows it'll be `C:\Users\YourUserName\Downloads\`. Depending on which version you downloaded, the file will end with `.csv` or `.rds`. Either one will work with R! For convenience, I'm renaming my file to `stanford-citation-data-okc.rds` -- you can also find the data in this GitHub repo, in the `spi-2023/data/okc/` directory.

Once you have the data and know where it is, we'll open a new script in RStudio (`File` > `New File` > `R Script`). You can think of these as literal scripts -- we're giving line-by-line instructions to R, telling it exactly what we want it to do along the way. At the end, we'll run the whole script together, and it will read in our data, analyze it, and produce our graphs, all with the press of a button. Incredible! It should open as a new pane in RStudio.

Save your script wherever you'd like, and then we'll add our first lines of R code! The first step, before we actually read in our data, is to install and load some **packages** that will help make our task easier. Packages are one of the best parts of R -- they're little libraries of code, usually to accomplish a specific task, that very smart people wrote to make our lives easier. Today, we'll need the following packages:

- `{dplyr}` -- this package provides easy and convenient functions for manipulating data. We can use it to filter and sort our data in various ways, add new variables / columns to our data, and much more.
- `{readr}` -- this package includes functions for reading in all sorts of data. It can handle `.csv` files as well as `.rds` files, so it's what we'll use to load up our data into R.
- `{ggplot2}` -- this is the premier graphing package in R. We'll be using it to make some fun graphs (and maybe even a map!) using our data.

You can install each of them using the R function `install.packages()`. All R functions use this `word()` format -- the word at the beginning tells R which function we're using, and the parentheses are where we'll put the "arguments" we're supplying to the function. In this case, the only argument we need to provide is to tell it which package we want to install.

In your R console, try typing the following:

`install.packages("dplyr")`
`install.packages("readr")`
`install.packages("ggplot2")`

You can type them straight into the console and press enter, or you can type them into your script and run the code yourself (using Ctrl+Enter, for example). R will do all the work, so just sit back and watch the paragraphs fly by. Also, all of these packages are a part of the [Tidyverse](https://www.tidyverse.org/), a series of packages that all work together to make data analysis in R easier and more accessible. If we want, we can install all of them (plus a few extras) in one go by typing `install.packages("tidyverse")`.

Once they're installed, we have to tell our script that we're going to use them. At the very top of our script, before anything else, we'll do so using the `library()` function. Type the following into your freshly made R Script (**not the console!**)

---
# SPI Session 2: Tulsa (July 20-21, 2023)
