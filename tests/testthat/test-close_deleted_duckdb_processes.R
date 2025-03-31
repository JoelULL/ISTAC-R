#
#
#
#
#(Añadir descripcion)
source("R/close_deleted_duckdb_processes.R")

test_that("close_deleted_duckdb_processes detecta y maneja procesos huérfanos", {
  
  # Mockear system para devolver procesos huérfanos simulados
  mock_system <- mock(c("duckdb (deleted)", "duckdb (deleted)"))
  stub(close_deleted_duckdb_processes, "system", mock_system)
  result <- close_deleted_duckdb_processes()
  expect_true(result)
  expect_called(mock_system, 1)
})

test_that("close_deleted_duckdb_processes no detecta procesos huérfanos", {
    
  mock_system <- mock(character(0))
  stub(close_deleted_duckdb_processes, "system", mock_system)

  result <- close_deleted_duckdb_processes()
  
  expect_null(result)
  expect_called(mock_system, 1)
})