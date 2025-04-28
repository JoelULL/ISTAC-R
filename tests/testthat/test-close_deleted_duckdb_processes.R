#' test file for close_deleted_duckdb_processes
#' @seealso [close_deleted_duckdb_processes]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html
#' This test also use the mockery strategy using the library mockery. See more:
#' https://cran.r-project.org/web/packages/mockery/index.html

test_that("close_deleted_duckdb_processes detects and handles orphaned processes", {
  skip_on_os(c("windows", "mac"))
  # Mock system to return mock orphaned processes
  mock_system <- mock(c("duckdb (deleted)", "duckdb (deleted)"))
  stub(close_deleted_duckdb_processes, "system", mock_system)
  result <- close_deleted_duckdb_processes()
  expect_true(result)
  expect_called(mock_system, 1)
})

test_that("close_deleted_duckdb_processes does not detect orphaned processes", {
  skip_on_os(c("windows", "mac"))
  mock_system <- mock(character(0))
  stub(close_deleted_duckdb_processes, "system", mock_system)

  result <- close_deleted_duckdb_processes()
  
  expect_null(result)
  expect_called(mock_system, 1)
})