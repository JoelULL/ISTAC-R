# Make packages required for development visible to renv

# library(languageserver)
# library(lintr)
# library(styler)
# library(testthat)
# library(mockery)
# library(plumber)
# library("spanishoddata")
# library("dplyr")
# library(DBI)
# library(uuid)
# library(RPostgres)
# library(duckdb)
# library(jsonlite)

required_packages <- c(
  "languageserver",
  "lintr",
  "styler",
  "testthat",
  "mockery",
  "plumber",
  "spanishoddata",
  "dplyr",
  "DBI",
  "uuid",
  "RPostgres",
  "duckdb",
  "jsonlite",
  "here",
  "zonebuilder",
  "tmaptools",
  "sf"
)

new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages) > 0) {
  install.packages(new_packages)
}

invisible(lapply(required_packages, library, character.only = TRUE))