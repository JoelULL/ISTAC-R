
json_data_download_configuration <- function(json_file_path) {
  params <- fromJSON(json_file_path, simplifyVector = FALSE)
  do.call(download_data_filtered_v2, params)
}
json_data_download_configuration("json_files/parameters.json")
