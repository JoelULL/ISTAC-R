#' test file for json_data_download_configuration
#' @seealso [json_data_download_configuration]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html

test_that("json_data_download_configuration reads JSON, parses correctly, and downloads data", {

  json_file_path <- here("json_files", "file_test.json")
  
  result <- json_data_download_configuration(json_file_path)
  
  expect_type(result, "list")
  expect_equal(result$status, "success")
  

  expect_true("db_path" %in% names(result))
  expect_type(result$db_path, "character")
  
  expect_true(file.exists(result$db_path))
})


