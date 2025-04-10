#' @description
#' This function creates a temporary directory to store the downloaded 
#' unfiltered data for each user
create_temp_dir <- function() {
  temp_dir <- file.path(tempdir(), paste0("od_data_", Sys.getpid()))
  dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
  return(temp_dir)
}