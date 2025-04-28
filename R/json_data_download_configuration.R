
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
