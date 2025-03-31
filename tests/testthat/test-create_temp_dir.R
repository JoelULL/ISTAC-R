#
#
#
#
#
#(Añadir descripción de estos test)

source("R/create_temp_dir.R")

test_that("create_temp_dir crea un directorio temporal válido", {

  temp_dir <- create_temp_dir()

  expect_type(temp_dir, "character")
  
  expect_true(nchar(temp_dir) > 0)
  
  expect_true(dir.exists(temp_dir))
  
  expect_match(temp_dir, "od_data_\\d+$", perl = TRUE)
  
  expect_no_error(create_temp_dir())
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("create_temp_dir crea un directorio en la ubicación correcta", {
  
  temp_dir <- create_temp_dir()
  expect_true(startsWith(temp_dir, tempdir()))
  
  unlink(temp_dir, recursive = TRUE)
})