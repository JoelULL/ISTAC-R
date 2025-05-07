source("R/close_deleted_duckdb_processes.R")
source("R/clean_duckdb_tmp_files.R")
#' @description
#' When deleted duckdb processes are detected, both functions
#' close_deleted_duckdb_processes and clean_duckdb_tmp_files
#' are executed with this function.
#' @seealso 
#' * [close_deleted_duckdb_processes] close deleted duckdb processes.
#' * [clean_duckdb_tmp_files] eliminates temporary files created 
#'   for duckdb processes.
close_orphan_duckdb_process <- function() {
    os <- Sys.info()[["sysname"]]
    if (os == "Linux" || os == "Darwin") {
        clean_duckdb_tmp_files()
        close_deleted_duckdb_processes()
    } else if ( os == "Windows") {
        gc(full = TRUE, verbose = FALSE)
    }

}