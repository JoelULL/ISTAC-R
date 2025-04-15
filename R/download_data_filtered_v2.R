download_data_filtered_v2 <- function(
    zones, start_date, end_date,
    type,
    param_codes,
    os_option = NULL,
    max_download_size = 1) {
      
  checkmate::assertChoice(type, choices = c("od", "os", "nt"), null.ok = FALSE)

  close_orphan_duckdb_process()

  tryCatch(
    {
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

      # table column names for checking
      col_names <- colnames(data_db)

      # e.g: id_origin, id_destination
      # accepted: ([id_origin, id_destination], [id_origin, id_destination_not_listed],
      # [id_origin_not_listed, id_destination])
      # not accepted: [id_origin_not_listed, id_destination_not_listed]
      if (length(param_codes) > 0) {
        for (var_name in names(param_codes)) {
          if (!(var_name %in% col_names)) {
            stop(paste("Parámetro", var_name, "no es una columna válida."))
          }
        }

        filter_conditions <- lapply(names(param_codes), function(var_name) {
          values <- param_codes[[var_name]]
          rlang::expr(!!rlang::sym(var_name) %in% !!values)
        })


        full_filter_expr <- Reduce(function(x, y) rlang::expr(!!x | !!y), filter_conditions)

        data_db <- data_db %>% filter(!!full_filter_expr)
      }

      filtered_data <- collect(data_db)

      user_id <- Sys.info()["user"]
      unique_id <- UUIDgenerate()
      final_db_path <- paste0("data/", user_id, "_", unique_id, "_filtered_data.duckdb")

      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
      DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)

      filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
      print(head(filtered_data_check))

      on.exit(
        {
          try(DBI::dbDisconnect(con), silent = TRUE)
        },
        add = TRUE
      )

      # print("Data base saved data/filtered_data.duckdb")

      on.exit(
        {
          try(spod_disconnect(data_db), silent = TRUE)
          try(gc(), silent = TRUE)
          try(unlink(temp_dir, recursive = TRUE), silent = TRUE)
        },
        add = TRUE
      )

      return(list(status = "success", db_path = final_db_path))
    },
    error = function(e) {
      return(list(status = "error", message = e$message))
    }
  )
}


# in-code test
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
result