test_that("json_data_download_and_migrate mocks working", {
  config <- list(
    download = list(param_codes = list(list("A", "B")), other_param = 123),
    postgres = list(
      pg_dbname = "testdb", pg_host = "localhost", pg_port = 5432,
      pg_user = "user", pg_password = "pass", delete_duckdb_file = FALSE
    )
  )
  json_path <- tempfile(fileext = ".json")
  write_json(config, json_path, auto_unbox = TRUE)

  mock_download <- mock(list(status = "success", db_path = "fake_duckdb_path"))
  mock_migrate <- mock(NULL)

  stub(json_data_download_and_migrate, "download_data_filtered_v2", mock_download)
  stub(json_data_download_and_migrate, "duckdb_to_postgre_migration", mock_migrate)

  expect_silent(json_data_download_and_migrate(json_path))
  expect_called(mock_download, 1)
  expect_called(mock_migrate, 1)
})

test_that("json_data_download_and_migrate lanza error si falla la descarga", {
  config <- list(
    download = list(param_codes = list(list("A", "B")), other_param = 123),
    postgres = list(
      pg_dbname = "testdb", pg_host = "localhost", pg_port = 5432,
      pg_user = "user", pg_password = "pass", delete_duckdb_file = FALSE
    )
  )
  json_path <- tempfile(fileext = ".json")
  write_json(config, json_path, auto_unbox = TRUE)

  mock_download_fail <- mock(list(status = "fail", message = "Error de descarga"))

  stub(json_data_download_and_migrate, "download_data_filtered_v2", mock_download_fail)

  expect_error(json_data_download_and_migrate(json_path), "Download failed")
})