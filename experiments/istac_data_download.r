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
install.packages("tidyverse")
library(DBI)
library(spanishoddata)
library(dplyr)
library(tidyverse)
## Creates the directory if it doesn't exist
spod_set_data_dir(data_dir = "~/spanish_od_data")

##### spanishoddata test

## download and convert data to duckDB (less memory usage)
#specific dates to download. This is just an example.
dates_1 <- c(start = "2022-02-17", end = "2022-02-18")
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
print("debug")
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
filtered_data<-collect(selected_places)
filtered_data
view(filtered_data)
selected_places %>% print(n = 100)
number_of_rows <- nrow(selected_places)
print(number_of_rows) #this doesn't work because is not loaded to memory (?)

spod_disconnect(my_od_data_2)
#dbDisconnect(conn)
#####
options(spanishoddata.graphql_api_endpoint = "https://mapas-movilidad.transportes.gob.es/api/graphql")

getOption("spanishoddata.graphql_api_endpoint")


library(spanishoddata)
library(dplyr)
library(stringr)

?spod_convert


##check spod_quick_get_od()
od_quick <- spod_quick_get_od(
    date = "2022-01-01" ,
    min_trips = 1000
)
od_quick

#####################
install.packages("httr2")
install.packages("jsonlite")
library(httr2)
library(jsonlite)

# Construye la consulta GraphQL
query <- '{
  find_journeys_mun_criteria(journeysMunCriteria: {
    date: "20220101",
    min_journeys: 100,
    distances: ["D_05_2", "D_2_10", "D_10_50", "D_50"],
    origin_muni: ["01002"],
    target_muni: ["01002"]
  }) {
    journeys
    journeys_km
    origin_muni
    target_muni
  }
}'

# Prepara el cuerpo de la solicitud
body <- list(
  query = query,
  variables = list(
    journeysMunCriteria = list(
      date = "20220101",
      min_journeys = 100,
      distances = c("D_05_2", "D_2_10", "D_10_50", "D_50"),
      origin_muni = c("01002"),
      target_muni = c("01002")
    )
  )
)

# Convierte el cuerpo a JSON
body_json <- jsonlite::toJSON(body, auto_unbox = TRUE)

# Envía la solicitud POST
response <- httr2::request(
  "POST",
  url = "https://mapas-movilidad.transportes.gob.es/api/graphql",
  body = body_json,
  httr2::content_type_json()
)

# Procesa la respuesta
if (httr2::status_code(response) == 200) {
  data <- jsonlite::fromJSON(httr2::content(response, "text"), simplifyDataFrame = FALSE)
  # Procesa los datos según sea necesario
} else {
  stop("Error en la solicitud")
}

#############################
dates_3 <- c(start = "2022-02-17", end = "2022-02-18")
db_3 <- spod_convert(
 type = "os",
 zones = "dist",
 dates = dates_3,
 overwrite = TRUE
)

# now connect to the converted data
my_od_data_3 <- spod_connect(db_3)

#other way to connect to duckdb
#conn <- dbConnect(duckdb::duckdb(), db_2)

# Select all columns to show
all_data <- my_od_data_3 %>% select(everything())
# see result
print(all_data)

spod_disconnect(my_od_data_3)


#############
dates_4 <- c(start = "2022-02-17", end = "2022-02-18")
db_4 <- spod_convert(
 type = "nt",
 zones = "dist",
 dates = dates_4,
 overwrite = TRUE
)

# now connect to the converted data
my_od_data_4 <- spod_connect(db_4)

#other way to connect to duckdb
#conn <- dbConnect(duckdb::duckdb(), db_2)

# Select all columns to show
all_data <- my_od_data_4 %>% select(everything())
# see result
print(all_data)

spod_disconnect(my_od_data_4)

municip_v2 <- spod_get_zones(zones = "municipalities", ver = 2)
municip_v2

distr_v1 <- spod_get_zones(zones = "districts", ver = 1)
distr_v1