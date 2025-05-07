#' This function eliminates temporary files created for duckdb processes.
clean_duckdb_tmp_files <- function() {
  tmp_files <- list.files(path = "/tmp", pattern = "duckdb", full.names = TRUE, recursive = TRUE)
  file.remove(tmp_files)
}