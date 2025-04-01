#
#
#
#
#
#(Añadir descripción de estos test)

#source("R/clean_duckdb_tmp_files.R")

test_that("clean_duckdb_tmp_files elimina archivos coincidentes", {
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


test_that("clean_duckdb_tmp_files no elimina archivos no coincidentes", {

  non_matching_file <- tempfile(pattern = "otherfile_", tmpdir = "/tmp")
  file.create(non_matching_file)
  
  expect_true(file.exists(non_matching_file))
  
  clean_duckdb_tmp_files()
  
  expect_true(file.exists(non_matching_file))
  
  unlink(non_matching_file)
})

test_that("clean_duckdb_tmp_files maneja correctamente la ausencia de archivos", {

  matching_files <- list.files(path = "/tmp", pattern = "duckdb", full.names = TRUE, recursive = TRUE)
  if (length(matching_files) > 0) {
    unlink(matching_files)
  }
  
  expect_no_error(clean_duckdb_tmp_files())
})

