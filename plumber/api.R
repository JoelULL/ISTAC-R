#' API endpoints file
#' @description
#' This file includes the endpoints developed for the API.
#' It use the plumber package. More info:
#' https://www.rplumber.io/
#' https://cran.r-project.org/web/packages/plumber/index.html


# api.R
#* @apiTitle Data Filtering API
#* @apiDescription Data Filtering API using DuckDB


#* Filter and download data according to parameters
#* @param zones zone types (ex: "muni")
#* @param start_date initial date (YYYY-MM-DD)
#* @param end_date end date (YYYY-MM-DD)
#* @param type data type ("od", "os", "nt")
#* @param param_codes Code list (ex: ["38","35"])
#* @param os_option  "os" type ("residences"/"overnight_stays")
#* @post /filter-data
function(
  zones, 
  start_date, 
  end_date,
  type,
  param_codes,
  os_option = NULL
) {
  # Convert param_codes JSON to vector?
  param_codes <- unlist(param_codes)
  
  result <- download_data_filtered_v2(
    zones = zones,
    start_date = start_date,
    end_date = end_date,
    type = type,
    param_codes = param_codes
  )
  
  if (result$status == "success") {
    # returns generated duckdb file path
    list(
      status = "success",
      download_link = paste0("http://localhost:8000/download/", result$db_path)
    )
  } else {
    # Devolver error detallado
    list(
      status = "error",
      message = result$message
    )
  }
}

###generate endpoint to download filtered data to user (Migrate first to postgre?)