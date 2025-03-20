library("spanishoddata")
library("dplyr")

### GAU == LUA

spod_set_data_dir(data_dir = "~/spanish_od_data")


##close duckDB processes
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


#download data from start date to end date: od--> origen-destino 
download_data_province_code_origin_destination <- function(type, zones, start_date, end_date, 
  ine_codes, max_download_size = 1) {
  ### falta validar datos de entrada, aquí o en el tryCatch
  ##(o especificar una variable aqui con los dos códigos)
  close_deleted_duckdb_processes()
  tryCatch({
    dates =c(start = start_date, end = end_date)
    
    db <- spod_convert(
        type = type,
        zones = zones,
        dates = dates,
        overwrite = TRUE
    )

    data_db <- spod_connect(db)

    provinces_ine_codes<- ine_codes #quiza esto no hace falta y se puede hacer directamente en la linea siguiente.
                                    #si se pasa en un formato correcto.
    selected_places <- data_db %>% filter(residence_province_ine_code %in% provinces_ine_codes)
    filtered_data <- collect(selected_places)
    ##debug
    #selected_places %>% print(n = 100)
    ##end-debug
    spod_disconnect(data_db)
   
    #Eliminar la fuente principal de datos para liberar memoria
    gc()
    unlink("~/spanish_od_data/", recursive = TRUE)
    
    return(filtered_data)
    
    #se debe eliminar los datos de los que se parten para liberar espacio de disco, una vez se ha obtenido los datos pedidos

  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}

#download data from start date to end date: os -->Pernoctaciones
download_data_id_residence_overnight_stays <- function(type, zones, start_date, end_date, 
  id_residences, max_download_size = 1) {
    ### se puede forzar el tipo a os en esta funcion
    ### falta validar datos de entrada, aquí o en el tryCatch
  close_deleted_duckdb_processes()
  tryCatch({
    dates =c(start = start_date, end = end_date)
    
    db <- spod_convert(
        type = type,
        zones = zones,
        dates = dates,
        overwrite = TRUE
    )

    data_db <- spod_connect(db)

    ids_residence <- id_residences ## si se pasa en un formato correcto esto no hace falta, validar primero
    
    selected_places <- data_db %>% filter(ids_residence %in% id_residence)
    #####hacer un collect() para almacenar el resultado y ver donde se almacena
    selected_places %>% print(n = 100)

    spod_disconnect(data_db)

  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}


download_data_id_overnight_stay_overnight_stays <- function(type, zones, start_date, end_date, 
  id_overnight_stays, max_download_size = 1) {
    ### se puede forzar el tipo a os en esta funcion
    ### falta validar datos de entrada, aquí o en el tryCatch
  close_deleted_duckdb_processes()
  tryCatch({
    dates =c(start = start_date, end = end_date)
    
    db <- spod_convert(
        type = type,
        zones = zones,
        dates = dates,
        overwrite = TRUE
    )

    data_db <- spod_connect(db)

    ids_overnight_stay <- id_overnight_stays ## si se pasa en un formato correcto esto no hace falta, validar primero
    
    selected_places <- data_db %>% filter(ids_overnight_stay %in% id_overnight_stay)
    #####hacer un collect() para almacenar el resultado y ver donde se almacena
    selected_places %>% print(n = 100)

    spod_disconnect(data_db)

  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}

##Parece que la función para nt usa los datos de la tabla que se especifica en la metodología:
# 4.2.2 Viajes por persona
#Asegurar esto porque la función al utilizar el parametro nt, al cargar la tabla añade los meses, los años y los días
#puede que no sea la misma tabla o internamente, la libería carga esos datos en la tabla igualmente (pasa lo mismo en el resto de tablas luego si es esto)
download_data_id_overnight_stay_trips_per_person <- function(type, zones, start_date, end_date, 
  id_overnight_stays, max_download_size = 1) {
    ### se puede forzar el tipo a os en esta funcion
    ### falta validar datos de entrada, aquí o en el tryCatch
  close_deleted_duckdb_processes()
  tryCatch({
    dates =c(start = start_date, end = end_date)
    
    db <- spod_convert(
        type = type,
        zones = zones,
        dates = dates,
        overwrite = TRUE
    )

    data_db <- spod_connect(db)

    ids_overnight_stay <- id_overnight_stays ## si se pasa en un formato correcto esto no hace falta, validar primero
    
    selected_places <- data_db %>% filter(ids_overnight_stay %in% id)
    #####hacer un collect() para almacenar el resultado y ver donde se almacena
    selected_places %>% print(n = 100)

    spod_disconnect(data_db)

  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}

##output functions test
#od data per provinces
ine_codes <- c("38","35")
show_od_data <- download_data_province_code_origin_destination("od","muni","2022-01-01","2022-01-02", ine_codes)
show_od_data #si el archivo de almacenado de datos se elimina hay que ver donde se almacena esto
#os data per id_residence
ids_r <- c("01001")
download_data_id_residence_overnight_stays("os","muni","2022-01-01","2022-01-02", ids_r)

#os data per id_stay
ids_os <- c("01001")
download_data_id_residence_overnight_stays("os","muni","2022-01-01","2022-01-02", ids_os)

#os data per id_over_night_stay
ids_ovs <- c("01001")
download_data_id_overnight_stay_trips_per_person("nt","muni","2022-01-01","2022-01-02", ids_ovs)