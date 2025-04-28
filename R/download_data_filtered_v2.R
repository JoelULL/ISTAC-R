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
#' @param param_codes list of parameters to filter
#'  (e.g. province codes or IDs of other locations.)
#' @param max_download_size spanishoddata parameter.
#'  The maximum download size in gigabytes. Defaults to 1.
#' @return If success: a list with the status = "success",
#'  and the final db filtered file path
#' @return If error: a list with the status = "error" and the error message.

download_data_filtered_v2 <- function(
    zones, start_date, end_date,
    type,
    param_codes,
    os_option = NULL,
    max_download_size = 1) {
  # checkmate::assertChoice(type, choices = c("od", "os", "nt"), null.ok = FALSE)
  print(str(param_codes))
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

      data_db <- data_db %>% as.data.frame()
      

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

      # windows fix
      dir.create(dirname(final_db_path), recursive = TRUE, showWarnings = FALSE)

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
# result <- download_data_filtered_v2(
#   zones = "muni",
#   start_date = "2022-01-01",
#   end_date = "2022-01-02",
#   type = "od",
#   param_codes = list(
#     #id_origin = c("01059", "02003", "03014"),
#     #id_destination = c("02003", "03014")
#     id_origin = c("01059")
#   )
# )
# result

