#' test file for create_temp_dir
#' @seealso [create_temp_dir]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html


test_that("create_temp_dir creates a valid temporary directory", {

  temp_dir <- create_temp_dir()

  expect_type(temp_dir, "character")
  
  expect_true(nchar(temp_dir) > 0)
  
  expect_true(dir.exists(temp_dir))
  
  expect_match(temp_dir, "od_data_\\d+$", perl = TRUE)
  
  expect_no_error(create_temp_dir())
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("create_temp_dir creates a directory in the correct location", {
  
  temp_dir <- create_temp_dir()
  expect_true(startsWith(temp_dir, tempdir()))
  
  unlink(temp_dir, recursive = TRUE)
})