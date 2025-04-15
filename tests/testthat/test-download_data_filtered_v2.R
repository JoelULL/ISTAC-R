test_that("download_data_filtered_v2 filtra con OR correctamente", {

  mock_df <- tibble::tibble(
    id_origin = c("01059", "99999", "02003", "88888"),
    id_destination = c("99999", "03014", "00000", "77777"),
    value = c(1, 2, 3, 4)
  )
  
  # Mocks
  mock_spod_convert <- mock("mock_db_path")
  mock_spod_connect <- mock(mock_df)
  mock_spod_set_data_dir <- mock(NULL)
  mock_close <- mock(NULL) 
  
  # Stubs
  stub(download_data_filtered_v2, "spod_convert", mock_spod_convert)
  stub(download_data_filtered_v2, "spod_connect", mock_spod_connect)
  stub(download_data_filtered_v2, "spod_set_data_dir", mock_spod_set_data_dir)
  stub(download_data_filtered_v2, "close_orphan_duckdb_process", mock_close)
  

  result <- download_data_filtered_v2(
    zones = "muni",
    start_date = "2022-01-01",
    end_date = "2022-01-02",
    type = "od",
    param_codes = list(
      id_origin = c("01059", "02003", "03014"),
      id_destination = c("02003", "03014")
    )
  )
  

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = result$db_path)
  filtered_data <- DBI::dbReadTable(con, "filtered_table")
  

  expect_true(all(
    filtered_data$id_origin %in% c("01059", "02003", "03014") | 
    filtered_data$id_destination %in% c("02003", "03014")
  ))
  

  DBI::dbDisconnect(con)
})
