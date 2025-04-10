#' test file for download_data_filtered
#' @seealso [download_data_filtered]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html
test_that("download_data_filtered throws an error for unrecognized types", {
  codes <- c("38", "35")
  
  #lsof warnings excluded for testing
  result <- suppressWarnings(download_data_filtered(
    zones = "muni",
    start_date = "2022-01-01",
    end_date = "2022-01-02",
    type = "ok", 
    param_codes = codes
  ))

  expect_equal(result$status, "error")
  expect_match(
    result$message,
    "Assertion on 'type' failed: Must be element of set {'od','origin-destination','os','overnight_stays','nt','number_of_trips'}, but is 'ok'.",
    fixed = TRUE
  )
})


