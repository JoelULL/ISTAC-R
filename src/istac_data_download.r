# Necessary package installation to access data.
# for more information about it visit:
# https://ropenspain.github.io/spanishoddata/articles/v2-2022-onwards-mitma-data-codebook
install.packages("spanishoddata")
# This package is necessary if you are using GitHub CodeSpaces:
# for more information about it visit:
# https://cran.r-project.org/web/packages/remotes/index.html
install.packages("remotes")
# Newer version of this package fails on CodeSpaces, this version works fine.
# for more information about it visit:
# https://cran.r-project.org/web/packages/units/index.html
remotes::install_version("units", version = "0.8-5")
## Necessary package for db
library(DBI)
library(spanishoddata)
library(dplyr)
install.packages("tidyverse")
library(tidyverse)
## Creates the directory if it doesn't exist
spod_set_data_dir(data_dir = "~/spanish_od_data")

##### spanishoddata test

## download and convert data to duckDB (less memory usage)
#specific dates to download. This is just an example.
dates_1 <- c(start = "2020-02-17", end = "2020-02-18")
db_2 <- spod_convert(
 type = "od",
 zones = "muni",
 dates = dates_1,
 overwrite = TRUE
)

# now connect to the converted data
my_od_data_2 <- spod_connect(db_2)

#other way to connect to duckdb
#conn <- dbConnect(duckdb::duckdb(), db_2)

# Select all columns to show
all_data <- my_od_data_2 %>% select(everything())
# see result
print(all_data)
##if collect is not used data will not be writed

# select only this places
# INE province codes for:
# Santa Cruz de Tenerife: 38
# Las Palmas de Gran Canaria: 35
provincias_interes <- c("38", "35")
selected_places <- my_od_data_2 %>% filter(residence_province_ine_code %in% provincias_interes)
# collect() this will load the desired data
# A very basic way to print the result table, just shows 10 rows.
# print(selected_places)
# To show more than 10 rows use:
selected_places %>% print(n = 100)
number_of_rows <- nrow(selected_places)
print(number_of_rows) #this doesn't work because is not loaded to memory (?)

spod_disconnect(my_od_data_2)
#dbDisconnect(conn)
#####
