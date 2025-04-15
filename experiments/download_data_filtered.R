source("R/create_temp_dir.R")
source("R/close_orphan_duckdb_process.R")

#' This function allows parameterized downloads of the data.
#' 
#' @description 
#' It use the spanishoddata library, to download and convert to DuckDB the files.
#' Then the parameters are used to filter the database, obtaining only the 
#' desired data in a duckdb file.
#' The directory where the data files are downloaded is unique for each user and
#' this directory is deleted at the end.
#' The resulting duckdb file is saved with a unique file name for each convertion.
#' @param zones spanishoddata parameter. The zones for which to download the data: 
#'  "districts", "dist", "distr", "distritos", "municipalities", "muni", "municip", 
#'  "municipios", "lua", "large_urban_areas", "gau", "grandes_areas_urbanas"
#' @param start_date Start date of the data. Use the format "YYYY-MM-DD"
#' @param end_date End date of the data. Use the same format as the start date
#' @param type spanishoddata parameter. The type of data to download. Can be: 
#'  "od" "os", "nt".
#'  os and overnight_stays is only for the v2 data. 
#'  More info: https://ropenspain.github.io/spanishoddata/index.html 
#' @param param_codes Vector of filter codes 
#'  (e.g. province codes or IDs of other locations.)
#' @param os_option For "os": allows you to choose the filtering.
#'  It can be: "residences" or "overnight_stays".
#' @param max_download_size spanishoddata parameter.
#'  The maximum download size in gigabytes. Defaults to 1.
#' @return If success: a list with the status = "success", 
#'  and the final db filtered file path
#' @return If error: a list with the status = "error" and the error message. 

download_data_filtered <- function(
  zones, start_date, end_date,
  type,              
  param_codes,       
  os_option = NULL,  
  max_download_size = 1
) {
  
  close_orphan_duckdb_process()
  
  tryCatch({
    temp_dir <- create_temp_dir()
    print(temp_dir)
    spod_set_data_dir(temp_dir)
    db_path <- file.path(temp_dir, "raw_data.duckdb")
    
    dates <- c(start = start_date, end = end_date)
    
    db <- spod_convert(
      type = type,
      zones = zones,
      dates = dates,
      overwrite = TRUE
    )
    
    data_db <- spod_connect(db)
    
    selected_places <- switch(type,
      "od" = {
        data_db %>% filter(residence_province_ine_code %in% param_codes ) 
      },
      "os" = {
        if (is.null(os_option)) {
          stop("For the 'os' type the 'os_option' parameter must be specified")
        }
        if (os_option == "residences") {
          data_db %>% filter(param_codes %in% id_residence)
        } else if (os_option == "overnight_stays") {
          data_db %>% filter(param_codes %in% id_overnight_stay)
        } else {
          stop("Not a valid option for os_option")
        }
      },
      "nt" = {
        data_db %>% filter(param_codes %in% id)
      },
      {
        stop("Error. Unknown type")
      }
    )
    
    filtered_data <- collect(selected_places)
    
    # final_db_path <- "data/filtered_data.duckdb"
    user_id <- Sys.info()["user"]
    unique_id <- UUIDgenerate()
    final_db_path <- paste0("data/", user_id, "_", unique_id, "_filtered_data.duckdb")
    
    
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
    DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)
    
    # User information
    filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
    print(head(filtered_data_check))

    on.exit({
      try(DBI::dbDisconnect(con), silent = TRUE)
    }, add = TRUE)
    
    # User information
    print("Data base saved data/filtered_data.duckdb")
    
    on.exit({
      try(spod_disconnect(data_db), silent = TRUE)
      try(gc(), silent = TRUE)
      try(unlink(temp_dir, recursive = TRUE), silent = TRUE)
    }, add = TRUE)
    # spod_disconnect(data_db)
    # gc()
    # unlink(temp_dir, recursive = TRUE)
    return(list(status = "success", db_path = final_db_path))
    
  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}


# #in-code test
# codes <- c("38", "35")
# show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-08", "od", codes)
# show_data

# ids <- c("01001")
# show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "os", ids, os_option = "residences")
# show_data

# ids <- c("01001")
# show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "os", ids, os_option = "overnight_stays")
# show_data

# ids <- c("01001")
# show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "nt", ids)
# show_data