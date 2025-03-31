# creating temporary directory to store data for each user
#
#
#
# (complete description here)
create_temp_dir <- function() {
  temp_dir <- file.path(tempdir(), paste0("od_data_", Sys.getpid()))
  dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
  return(temp_dir)
}