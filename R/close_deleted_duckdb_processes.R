#close deleted duckdb processes
#
#
#
#
# (complete description here)
close_deleted_duckdb_processes <- function() {
  # if (Sys.info()["sysname"] == "Windows") {
  #   # En Windows se maneja de forma diferente
  #   return(invisible(NULL))
  # }
  tryCatch({
    lsof_output <- system("lsof | grep duckdb | grep '(deleted)'", intern = TRUE)
    if (length(lsof_output) > 0) {
      message("Detectados ", length(lsof_output), " procesos DuckDB huérfanos. Intentando liberar recursos...")
      gc(full = TRUE, verbose = FALSE)
      return(TRUE)
    }
  }, error = function(e) {
    gc(full = TRUE, verbose = FALSE)
    return(FALSE)
  })
  
  return(invisible(NULL))
}
close_deleted_duckdb_processes()



