#' test file for get_ine_codes
#' @seealso [get_ine_codes]
#' @description 
#' This test files covers the main functionality of this function.
#' The test are self-explanatory with a description.
#' The library used for testing is Testthat. See more:
#' https://testthat.r-lib.org/
#' https://cran.r-project.org/web/packages/testthat/index.html

mock_spod_get_zones <- function(option, ver) {
  data.frame(
    id = c("001", "002", "003", "004", "005"),
    geometry = I(rep("fake_geometry", 5))
  )
}
mock_zb_zone <- function(zone) {
  switch(zone,
         "El Hierro" = 1,
         "La Gomera" = 2,
         "La Palma" = 3,
         "Tenerife" = 4,
         "Gran Canaria" = 5,
         "Lanzarote" = 99,
         integer(0))
}

mock_st_simplify <- function(x, ...) x
mock_st_transform <- function(x, ...) x

test_that("get_ine_codes devuelve los códigos esperados", {
  stub(get_ine_codes, "spod_get_zones", mock_spod_get_zones)
  stub(get_ine_codes, "zonebuilder::zb_zone", mock_zb_zone)
  stub(get_ine_codes, "sf::st_simplify", mock_st_simplify)
  stub(get_ine_codes, "sf::st_transform", mock_st_transform)

  zones <- c("El Hierro", "La Gomera", "La Palma", "Tenerife", "Gran Canaria")
  result <- get_ine_codes("gau", zones, 2)

  expect_type(result, "character")
  expect_equal(sort(result), c("001", "002", "003", "004", "005"))
})
