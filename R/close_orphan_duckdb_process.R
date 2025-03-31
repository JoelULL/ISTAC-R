#
#
#
#
#
#
source("R/close_deleted_duckdb_processes.R")
source("R/clean_duckdb_tmp_files.R")
close_orphan_duckdb_process <- function() {
    clean_duckdb_tmp_files()
    close_deleted_duckdb_processes()
}