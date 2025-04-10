#' test file for clean_duckdb_tmp_files
#' @seealso [clean_duckdb_tmp_files]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html

test_that("clean_duckdb_tmp_files deletes matching files", {
  tmp_file1 <- tempfile(pattern = "duckdb_test1", tmpdir = "/tmp")
  tmp_file2 <- tempfile(pattern = "duckdb_test2", tmpdir = "/tmp")
  file.create(tmp_file1)
  file.create(tmp_file2)
  
  expect_true(file.exists(tmp_file1))
  expect_true(file.exists(tmp_file2))
  
  clean_duckdb_tmp_files()
  
  expect_false(file.exists(tmp_file1))
  expect_false(file.exists(tmp_file2))
})

test_that("clean_duckdb_tmp_files does not delete unmatched files", {

  non_matching_file <- tempfile(pattern = "otherfile_", tmpdir = "/tmp")
  file.create(non_matching_file)
  
  expect_true(file.exists(non_matching_file))
  
  clean_duckdb_tmp_files()
  
  expect_true(file.exists(non_matching_file))
  
  unlink(non_matching_file)
})

test_that("clean_duckdb_tmp_files correctly handles missing files", {

  matching_files <- list.files(path = "/tmp", pattern = "duckdb", full.names = TRUE, recursive = TRUE)
  if (length(matching_files) > 0) {
    unlink(matching_files)
  }
  expect_no_error(clean_duckdb_tmp_files())
})

