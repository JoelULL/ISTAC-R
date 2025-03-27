library("spanishoddata")
library("dplyr")

### GAU == LUA

spod_set_data_dir(data_dir = "~/spanish_od_data")


## close duckDB processes
close_deleted_duckdb_processes <- function() {
  # Ejecutar lsof para encontrar procesos relacionados con DuckDB
  processes <- system("lsof | grep duckdb", intern = TRUE)

  if (length(processes) == 0) {
    cat("No DuckDB processes detected.\n")
    return()
  }

  # Filtrar procesos que contienen (deleted)
  deleted_processes <- grep("\\(deleted\\)", processes, value = TRUE)

  # Extraer PIDs de procesos con archivos (deleted)
  deleted_pids <- as.integer(sapply(deleted_processes, function(line) strsplit(line, " ")[[1]][2]))

  # Verificar si hay PIDs para eliminar
  if (length(deleted_pids) > 0 && !all(is.na(deleted_pids))) {
    cat("Cerrando los siguientes procesos relacionados con archivos (deleted):\n")
    print(deleted_pids)

    for (pid in deleted_pids) {
      system(paste("kill -9", pid))
    }

    cat("Todos los procesos relacionados con archivos (deleted) han sido cerrados.\n")
  } else {
    cat("No DuckDB processes with (deleted) detected.\n")
  }
}

# creating temporary directory to store data for each user
create_temp_dir <- function() {
  temp_dir <- file.path(tempdir(), paste0("od_data_", Sys.getpid()))
  dir.create(temp_dir, showWarnings = FALSE, recursive = TRUE)
  return(temp_dir)
}


# download data from start date to end date: od--> origen-destino
# max_download_size is customizable
download_data_province_code_origin_destination <- function(
    zones, start_date, end_date,
    ine_codes, max_download_size = 1) {
  # incoming data(dates and type of zones) is validated using spanishoddata functions
  close_deleted_duckdb_processes()
  tryCatch(
    {
      # province_ine_codes <- c("38", "35") #si se quiere hacer como constante

      temp_dir <- create_temp_dir()
      print(temp_dir)
      spod_set_data_dir(temp_dir)
      db_path <- file.path(temp_dir, "raw_data.duckdb")

      dates <- c(start = start_date, end = end_date)

      db <- spod_convert(
        type = "od",
        zones = zones,
        dates = dates,
        overwrite = TRUE
      )

      data_db <- spod_connect(db)

      provinces_ine_codes <- ine_codes
      selected_places <- data_db %>% filter(residence_province_ine_code %in% provinces_ine_codes)
      filtered_data <- collect(selected_places)
      ## debug
      # selected_places %>% print(n = 100)
      ## end-debug
      final_db_path <- "data/filtered_data.duckdb"

      # Crear conexión a la base de datos final
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)

      # Escribir los datos filtrados en la base de datos
      DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)

      ## debug
      filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
      print(head(filtered_data_check)) # Ver las primeras filas de la tabla
      ## end-debug

      # Cerrar la conexión
      DBI::dbDisconnect(con)

      print("Base de datos guardada en data/filtered_data.duckdb")


      spod_disconnect(data_db)

      # Eliminar la fuente principal de datos para liberar memoria
      gc()
      unlink(temp_dir, recursive = TRUE)

      return(list(status = "success", db_path = final_db_path))

      # se debe eliminar los datos de los que se parten para liberar espacio de disco, una vez se ha obtenido los datos pedidos
    },
    error = function(e) {
      return(list(status = "error", message = e$message))
    }
  )
}

# download data from start date to end date: os -->Pernoctaciones
download_data_id_residence_overnight_stays <- function(
    zones, start_date, end_date,
    id_residences, max_download_size = 1) {
  ### falta validar datos de entrada, aquí o en el tryCatch
  close_deleted_duckdb_processes()
  tryCatch(
    {
      temp_dir <- create_temp_dir()
      print(temp_dir)
      spod_set_data_dir(temp_dir)
      db_path <- file.path(temp_dir, "raw_data.duckdb")

      dates <- c(start = start_date, end = end_date)

      db <- spod_convert(
        type = "os",
        zones = zones,
        dates = dates,
        overwrite = TRUE
      )

      data_db <- spod_connect(db)

      ids_residence <- id_residences # validate first

      selected_places <- data_db %>% filter(ids_residence %in% id_residence)
      filtered_data <- collect(selected_places)
      ## debug
      # selected_places %>% print(n = 100)
      ## end-debug
      final_db_path <- "data/filtered_data.duckdb"

      # Stablish connection to final database
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
      DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)

      ## Debug
      filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
      print(head(filtered_data_check)) # Ver las primeras filas de la tabla
      ## end-debug
      DBI::dbDisconnect(con)

      print("Base de datos guardada en data/filtered_data.duckdb")

      spod_disconnect(data_db)

      gc()
      unlink(temp_dir, recursive = TRUE)

      return(list(status = "success", db_path = final_db_path))
    },
    error = function(e) {
      return(list(status = "error", message = e$message))
    }
  )
}

download_data_id_overnight_stay_overnight_stays <- function(
    zones, start_date, end_date,
    id_overnight_stays, max_download_size = 1) {
  ### falta validar datos de entrada, aquí o en el tryCatch
  close_deleted_duckdb_processes()
  tryCatch(
    {
      temp_dir <- create_temp_dir()
      print(temp_dir)
      spod_set_data_dir(temp_dir)
      db_path <- file.path(temp_dir, "raw_data.duckdb")

      dates <- c(start = start_date, end = end_date)

      db <- spod_convert(
        type = "os",
        zones = zones,
        dates = dates,
        overwrite = TRUE
      )

      data_db <- spod_connect(db)

      ids_overnight_stay <- id_overnight_stays # validate first

      selected_places <- data_db %>% filter(ids_overnight_stay %in% id_overnight_stay)
      filtered_data <- collect(selected_places)
      ## debug
      # selected_places %>% print(n = 100)
      ## end-debug
      final_db_path <- "data/filtered_data.duckdb"

      # Stablish connection to final database
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
      DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)

      ## Debug
      filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
      print(head(filtered_data_check)) # Ver las primeras filas de la tabla
      ## end-debug
      DBI::dbDisconnect(con)

      print("Base de datos guardada en data/filtered_data.duckdb")

      spod_disconnect(data_db)

      gc()
      unlink(temp_dir, recursive = TRUE)

      return(list(status = "success", db_path = final_db_path))
    },
    error = function(e) {
      return(list(status = "error", message = e$message))
    }
  )
}

## Parece que la función para nt usa los datos de la tabla que se especifica en la metodología:
# 4.2.2 Viajes por persona
# Asegurar esto porque la función al utilizar el parametro nt, al cargar la tabla añade los meses, los años y los días
# puede que no sea la misma tabla o internamente, la libería carga esos datos en la tabla igualmente (pasa lo mismo en el resto de tablas luego si es esto)
download_data_id_overnight_stay_trips_per_person <- function(
    zones, start_date, end_date,
    id_overnight_stays, max_download_size = 1) {
  ### falta validar datos de entrada, aquí o en el tryCatch
  close_deleted_duckdb_processes()
  tryCatch(
    {
      temp_dir <- create_temp_dir()
      print(temp_dir)
      spod_set_data_dir(temp_dir)
      db_path <- file.path(temp_dir, "raw_data.duckdb")

      dates <- c(start = start_date, end = end_date)

      db <- spod_convert(
        type = "nt",
        zones = zones,
        dates = dates,
        overwrite = TRUE
      )

      data_db <- spod_connect(db)

      ids_overnight_stay <- id_overnight_stays # validate first

      selected_places <- data_db %>% filter(ids_overnight_stay %in% id)
      filtered_data <- collect(selected_places)
      ## debug
      # selected_places %>% print(n = 100)
      ## end-debug
      final_db_path <- "data/filtered_data.duckdb"

      # Stablish connection to final database
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
      DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)

      ## Debug
      filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
      print(head(filtered_data_check)) # Ver las primeras filas de la tabla
      ## end-debug
      DBI::dbDisconnect(con)

      print("Base de datos guardada en data/filtered_data.duckdb")

      spod_disconnect(data_db)

      gc()
      unlink(temp_dir, recursive = TRUE)

      return(list(status = "success", db_path = final_db_path))
    },
    error = function(e) {
      return(list(status = "error", message = e$message))
    }
  )
}
## output functions test
# od data per provinces

# download_data_province_code_origin_destination <- function(zones, start_date, end_date,ine_codes, max_download_size = 1)
ine_codes <- c("38", "35")
show_od_data <- download_data_province_code_origin_destination("muni", "2022-01-01", "2022-01-02", ine_codes)
show_od_data
print("debug")
# os data per id_residence
ids_r <- c("01001")
show_os_data <- download_data_id_residence_overnight_stays("muni", "2022-01-01", "2022-01-02", ids_r)
show_os_data
# os data per id_stay
ids_os <- c("01001")
show_os_data1 <- download_data_id_overnight_stay_overnight_stays("muni", "2022-01-01", "2022-01-02", ids_os)
show_os_data1
# os data per id_over_night_stay
ids_ovs <- c("01001")
show_nt_data <- download_data_id_overnight_stay_trips_per_person("muni", "2022-01-01", "2022-01-02", ids_ovs)
show_nt_data