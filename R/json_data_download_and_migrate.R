json_data_download_and_migrate <- function(json_file_path) {

  json_content <- readLines(json_file_path, warn = FALSE) |> paste(collapse = "\n")
  config <- jsonlite::fromJSON(txt = json_content, simplifyVector = FALSE, simplifyDataFrame = FALSE)

  download_params <- config$download
  download_params$param_codes <- lapply(download_params$param_codes, unlist)

  download_result <- do.call(download_data_filtered_v2, download_params)

  if (download_result$status != "success") {
    stop(paste("Download failed:", download_result$message))
  }

  duckdb_file_path <- download_result$db_path

  postgres_params <- config$postgres

  duckdb_to_postgre_migration(
    duckdb_file_path = duckdb_file_path,
    pg_dbname = postgres_params$pg_dbname,
    pg_host = postgres_params$pg_host,
    pg_port = postgres_params$pg_port,
    pg_user = postgres_params$pg_user,
    pg_password = postgres_params$pg_password,
    delete_duckdb_file = postgres_params$delete_duckdb_file
  )
}
#in-code test
# json_data_download_and_migrate("json_files/file_test_migration.json")