library("spanishoddata")
library("dplyr")

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
# pseudocodigo:
# se le pasa el tipo y un parametro para los codigos (estos pueden ser codigos de provincias o de id de otros lugares)
# Una vez hecho el spod_convert con el tipo especifico, se debe pasar el type por un switch que actuaria de esta forma
# switch(type) {
#   case "od": {
#            ...code
#            selected_places <- data_db %>% filter(residence_province_ine_code %in% param_codes)
#            ...code
#   }
#   case "os": # este se divide en dos (?) {
#               #aqui se puede o bien preguntar si se desea uno u otro.
                #añadir un parametro extra para seleccionar uno u otro.
                #
#   case "nt": {
#           ...code
#           selected_places <- data_db %>% filter(ids_overnight_stay %in% id)
#           ...code
#   }
#   A partir de este codigo es igual hasta el final que las funciones creadas
download_data_filtered <- function(
  zones, start_date, end_date,
  type,              # Tipo de datos: "od", "os", "nt", etc.
  param_codes,       # Vector de códigos de filtrado (p.ej. códigos de provincias o id de otros lugares)
  os_option = NULL,  # Para "os": permite elegir el filtrado, por ejemplo, "residences" o "overnight_stays"
  max_download_size = 1
) {
  # Se asume que existen las funciones auxiliares:
  # close_deleted_duckdb_processes, create_temp_dir, spod_set_data_dir,
  # spod_convert, spod_connect, spod_disconnect
  
  close_deleted_duckdb_processes()
  
  tryCatch({
    # Crear y configurar directorio temporal
    temp_dir <- create_temp_dir()
    print(temp_dir)
    spod_set_data_dir(temp_dir)
    db_path <- file.path(temp_dir, "raw_data.duckdb")
    
    dates <- c(start = start_date, end = end_date)
    
    # Convertir y descargar datos según el tipo especificado
    db <- spod_convert(
      type = type,
      zones = zones,
      dates = dates,
      overwrite = TRUE
    )
    
    data_db <- spod_connect(db)
    
    # Filtrado según el tipo especificado usando switch
    selected_places <- switch(type,
      "od" = {
        # Filtrado para OD: utiliza residence_province_ine_code
        data_db %>% filter(residence_province_ine_code %in% param_codes ) 
      },
      "os" = {
        # Para "os" se puede dividir en dos filtrados. Se usa el parámetro os_option para elegir.
        if (is.null(os_option)) {
          stop("Para el tipo 'os' se debe especificar el parámetro 'os_option'")
        }
        if (os_option == "residences") {
          data_db %>% filter(param_codes %in% id_residence)
        } else if (os_option == "overnight_stays") {
          data_db %>% filter(param_codes %in% id_overnight_stay)
        } else {
          stop("Opción no válida para os_option")
        }
      },
      "nt" = {
        # Filtrado para NT: utiliza ids_overnight_stay
        data_db %>% filter(param_codes %in% id)
      },
      {
        stop("Tipo no reconocido")
      }
    )
    
    # Recoger los datos filtrados
    filtered_data <- collect(selected_places)
    
    # Definir el path final para la base de datos filtrada
    final_db_path <- "data/filtered_data.duckdb"
    
    # Conectar a la base de datos final y escribir la tabla filtrada
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
    DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)
    
    # Debug: mostrar algunas filas de la tabla resultante
    filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
    print(head(filtered_data_check))
    
    DBI::dbDisconnect(con)
    
    print("Base de datos guardada en data/filtered_data.duckdb")
    
    # Desconectar la base de datos origen y liberar recursos
    spod_disconnect(data_db)
    gc()
    unlink(temp_dir, recursive = TRUE)
    
    return(list(status = "success", db_path = final_db_path))
    
  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}

# download_data_filtered <- function(
#   zones, start_date, end_date,
#   type,              # Tipo de datos: "od", "os", "nt", etc.
#   param_codes,       # Vector de códigos de filtrado (p.ej. códigos de provincias o id de otros lugares)
#   os_option = NULL,  # Para "os": permite elegir el filtrado, por ejemplo, "residences" o "overnight_stays"
#   max_download_size = 1
# )

#in-code test
codes <- c("38", "35")
show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "od", codes)
show_data

ids <- c("01001")
show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "os", ids, os_option = "residences")
show_data

ids <- c("01001")
show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "os", ids, os_option = "overnight_stays")
show_data

ids <- c("01001")
show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "nt", ids)
show_data

