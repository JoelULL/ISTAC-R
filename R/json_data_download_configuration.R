#' Read JSON configuration and download data
#' 
#' @description
#' The function gets a JSON with the user configuration to download data. 
#' Then calls the download function with the specified parameters
#' @seealso [download_data_filtered_v2()] to download the data using
#' the spanishoddata library.
#' @param json_file_path JSON file with the user data download configuration
#' @example
#' json_data_download_configuration("json_files/parameters.json")

json_data_download_configuration <- function(json_file_path) {
  json_content <- readLines(json_file_path, warn = FALSE) |> paste(collapse = "\n")
  params <- jsonlite::fromJSON(
    txt = json_content, #fix: path file was deprecated
    simplifyVector = FALSE,  
    simplifyDataFrame = FALSE
  )
  params$param_codes <- lapply(params$param_codes, unlist)
  
  do.call(download_data_filtered_v2, params)
}

#incode test
#json_data_download_configuration("json_files/parameters.json")
