library("spanishoddata")
library("dplyr")
library(DBI)

source("R/create_temp_dir.R")
source("R/close_orphan_duckdb_process.R")

#download data filtered
#
#
#
#(complete description here)

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
  
  close_orphan_duckdb_process()
  
  tryCatch({
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
    
    selected_places <- switch(type,
      "od" = {
        data_db %>% filter(residence_province_ine_code %in% param_codes ) 
      },
      "os" = {
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
        data_db %>% filter(param_codes %in% id)
      },
      {
        stop("Tipo no reconocido")
      }
    )
    
    filtered_data <- collect(selected_places)
    
    # final_db_path <- "data/filtered_data.duckdb"
    user_id <- Sys.info()["user"]
    unique_id <- UUIDgenerate()
    final_db_path <- paste0("data/", user_id, "_", unique_id, "_filtered_data.duckdb")
    
    
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
    DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)
    
    # Debug
    filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
    print(head(filtered_data_check))
    #  on.exit({
#     try(DBI::dbDisconnect(con), silent = TRUE)
#   }, add = TRUE)
    on.exit({
      try(DBI::dbDisconnect(con), silent = TRUE)
    }, add = TRUE)
    
    print("Base de datos guardada en data/filtered_data.duckdb")
    
    
    on.exit({
      try(spod_disconnect(data_db), silent = TRUE)
      try(gc(), silent = TRUE)
      try(unlink(temp_dir, recursive = TRUE), silent = TRUE)
    }, add = TRUE)
    # spod_disconnect(data_db)
    # gc()
    # unlink(temp_dir, recursive = TRUE)
    
    return(list(status = "success", db_path = final_db_path))
    
  }, error = function(e) {
    return(list(status = "error", message = e$message))
  })
}

# function parameters:
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

# ## primera version
# download_data_filtered <- function(
#   zones, start_date, end_date,
#   type,              # Tipo de datos: "od", "os", "nt", etc.
#   param_codes,       # Vector de códigos de filtrado (p.ej. códigos de provincias o id de otros lugares)
#   os_option = NULL,  # Para "os": permite elegir el filtrado, por ejemplo, "residences" o "overnight_stays"
#   max_download_size = 1
# ) {
#   # Se asume que existen las funciones auxiliares:
#   # close_deleted_duckdb_processes, create_temp_dir, spod_set_data_dir,
#   # spod_convert, spod_connect, spod_disconnect
  
#   #close_deleted_duckdb_processes() 
  
#   tryCatch({
#     temp_dir <- create_temp_dir()
#     print(temp_dir)
#     spod_set_data_dir(temp_dir)
#     db_path <- file.path(temp_dir, "raw_data.duckdb")
    
#     dates <- c(start = start_date, end = end_date)
    
#     # Convertir y descargar datos según el tipo especificado
#     db <- spod_convert(
#       type = type,
#       zones = zones,
#       dates = dates,
#       overwrite = TRUE
#     )
    
#     data_db <- spod_connect(db)
    
#     # Filtrado según el tipo especificado usando switch
#     selected_places <- switch(type,
#       "od" = {
#         data_db %>% filter(residence_province_ine_code %in% param_codes ) 
#       },
#       "os" = {
#         if (is.null(os_option)) {
#           stop("Para el tipo 'os' se debe especificar el parámetro 'os_option'")
#         }
#         if (os_option == "residences") {
#           data_db %>% filter(param_codes %in% id_residence)
#         } else if (os_option == "overnight_stays") {
#           data_db %>% filter(param_codes %in% id_overnight_stay)
#         } else {
#           stop("Opción no válida para os_option")
#         }
#       },
#       "nt" = {
#         data_db %>% filter(param_codes %in% id)
#       },
#       {
#         stop("Tipo no reconocido")
#       }
#     )
    
#     # Recoger los datos filtrados
#     filtered_data <- collect(selected_places)
    
#     # Definir el path final para la base de datos filtrada
#     final_db_path <- "data/filtered_data.duckdb"
    
#     # Conectar a la base de datos final y escribir la tabla filtrada
#     con <- DBI::dbConnect(duckdb::duckdb(), dbdir = final_db_path)
#     DBI::dbWriteTable(con, "filtered_table", filtered_data, overwrite = TRUE)
    
#     # Debug: mostrar algunas filas de la tabla resultante
#     filtered_data_check <- DBI::dbReadTable(con, "filtered_table")
#     print(head(filtered_data_check))
    
#     DBI::dbDisconnect(con)
    
#     print("Base de datos guardada en data/filtered_data.duckdb")
    
#     # Desconectar la base de datos origen y liberar recursos
#     spod_disconnect(data_db)
#     gc()
#     unlink(temp_dir, recursive = TRUE)
    
#     return(list(status = "success", db_path = final_db_path))
    
#   }, error = function(e) {
#     return(list(status = "error", message = e$message))
#   })
# }

# codes <- c("38", "35")
# show_data <- download_data_filtered("muni", "2022-01-01", "2022-01-02", "od", codes)
# show_data


# clean_duckdb_tmp_files()