#' Close deleted duckdb processes

#' @description
#' This function deletes duckdb procesess that could still open when the program
#' is close in the middle of a duckdb convertion process, 
#' those that are marked as (deleted). 
#' Prevents bugs with the convertion of new tables.
close_deleted_duckdb_processes <- function() {
  tryCatch({
    lsof_output <- system("lsof | grep duckdb | grep '(deleted)'", intern = TRUE)
    if (length(lsof_output) > 0) {
      message("Detected ", length(lsof_output), " deleted duckdb processes. releasing resources...")
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



