#' test file for json_data_download_configuration
#' @seealso [json_data_download_configuration]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html

test_that("JSON file reading and param_codes converts to vectors correctly", {
  #json_file_path <- "ISTAC-R/json_files/file_test.json"
  json_file_path <- here("ISTAC-R", "json_files", "file_test.json")

  params <- fromJSON(
    json_file_path,
    simplifyVector = FALSE,  
    simplifyDataFrame = FALSE
  )
  params$param_codes <- lapply(params$param_codes, unlist)
  
  expect_equal(params$zones, "muni")
  expect_equal(params$start_date, "2022-01-01")
  expect_equal(params$end_date, "2022-01-02")
  expect_equal(params$type, "od")
  expect_equal(params$param_codes$id_origin, c("01059", "02003", "03014"))
  expect_equal(params$param_codes$id_destination, c("02003", "03014"))
  expect_type(params$param_codes$id_origin, "character")
  expect_type(params$param_codes$id_destination, "character")
})
