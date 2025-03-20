install.packages("httr2")
install.packages("jsonlite")
install.packages("stringr")
install.packages("spanishoddata")

library(httr2)
library(jsonlite)
library(stringr)
library(spanishoddata)


options(spanishoddata.graphql_api_endpoint = "https://mapas-movilidad.transportes.gob.es/api/graphql")

# Suponiendo que ya tienes acceso a la librería 'spanishoddata'
library(spanishoddata)

spod_quick_get_od_by_province <- function(
  province_code = NULL,  # Añadido parámetro para seleccionar provincia
  date = NA,
  min_trips = 100,
  distances = c("500m-2km", "2-10km", "10-50km", "50+km"),
  id_origin = NA,
  id_destination = NA
){
  # Validar entradas
  checkmate::assert_integerish(min_trips, lower = 0, null.ok = FALSE, max.len = 1)

  # Mapeo de distancias amigables para el usuario a valores esperados por GraphQL
  distance_mapping <- c(
    "500m-2km" = "D_05_2",
    "2-10km" = "D_2_10",
    "10-50km" = "D_10_50",
    "50+km" = "D_50"
  )
  # Traducir distancias amigables a las distancias de GraphQL
  graphql_distances <- unname(distance_mapping[distances])

  if (any(is.na(graphql_distances))) {
    stop("Invalid distance value. Allowed values are: ", 
          paste(names(distance_mapping), collapse = ", "))
  }

  checkmate::assert_character(id_origin, null.ok = TRUE)
  checkmate::assert_character(id_destination, null.ok = TRUE)

  # Convertir la fecha en formato YYYYMMDD
  if (is.character(date)) {
    if (grepl("^\\d{4}-\\d{2}-\\d{2}$", date)) {
      date <- as.Date(date)
    }
    else if (nchar(date) == 8 && grepl("^\\d{8}$", date)) {
      date <- as.Date(date, format = "%Y%m%d")
    } else {
      stop("Invalid date format. Use 'YYYY-MM-DD', 'YYYYMMDD', or a Date object.")
    }
  }

  if (inherits(date, "Date")) {
    date <- format(date, "%Y%m%d")
  } else {
    stop("Invalid date input. Must be a character in 'YYYY-MM-DD'/'YYYYMMDD' format or a Date object.")
  }

  # Convertir fechas válidas a rangos
  convert_to_ranges <- function(dates) {
    dates <- as.Date(dates)
    ranges <- tibble::tibble(date = dates) |>
      dplyr::arrange(date) |>
      dplyr::mutate(
        diff = c(0, diff(date)),
        group = cumsum(diff != 1)
      ) |>
      dplyr::group_by(.data$group) |>
      dplyr::summarise(
        start = dplyr::first(date),
        end = dplyr::last(date),
        .groups = "drop"
      )
    range_strings <- ranges |>
      dplyr::mutate(range = paste(.data$start, "to", .data$end)) |>
      dplyr::pull(range)
    return(range_strings)
  }

  # Comprobar si la fecha está dentro de un rango válido
  valid_dates <- spod_get_valid_dates(ver = 2)
  is_valid_date <- lubridate::ymd(date) %in% valid_dates
  if (!is_valid_date) {
    stop(
      paste0("Invalid date. Must be within valid range: ",
             paste(convert_to_ranges(valid_dates), collapse = ", "))
    )
  }

  # Leer referencias de municipios
  muni_ref <- readRDS(
    system.file("extdata", "muni_v2_ref.rds", package = "spanishoddata")
  )

  validate_muni_ids <- function(muni_ids, muni_ref) {
    if (is.null(muni_ids) || length(muni_ids) == 0 || all(is.na(muni_ids))) {
      return(TRUE)
    }
    invalid_ids <- setdiff(muni_ids, muni_ref$id)
    if (length(invalid_ids) > 0) {
      stop(
        "Invalid municipality IDs detected: ",
        paste(invalid_ids, collapse = ", "),
        ". Please provide valid municipality IDs."
      )
    }
    return(TRUE)
  }

  if (!is.null(id_origin) && length(id_origin) > 0 && !all(is.na(id_origin))) {
    validate_muni_ids(id_origin, muni_ref)
  }
  if (!is.null(id_destination) && length(id_destination) > 0 && !all(is.na(id_destination))) {
    validate_muni_ids(id_destination, muni_ref)
  }

  # Crear el criterio de búsqueda para la consulta GraphQL
  journeysMunCriteria <- list(
    date = date,
    min_journeys = min_trips
  )

  # Añadir distancias si se proporcionan
  journeysMunCriteria$distances <- graphql_distances

  # Añadir id_origin y id_destination solo si no son NA
  if (!is.null(id_origin) && length(id_origin) > 0 && !all(is.na(id_origin))) {
    journeysMunCriteria$origin_muni <- id_origin
  }
  if (!is.null(id_destination) && length(id_destination) > 0 && !all(is.na(id_destination))) {
    journeysMunCriteria$target_muni <- id_destination
  }

  # Filtrar por provincia si se ha proporcionado
  if (!is.null(province_code)) {
    journeysMunCriteria$province_code <- province_code
  }

  # Definir el endpoint de GraphQL
  graphql_endpoint <- getOption("spanishoddata.graphql_api_endpoint")

  # Construir la consulta GraphQL
  graphql_query <- list(
    query = paste(
      collapse = " ",
      c(
        "query ($journeysMunCriteria: JourneysMunCriteriaGqlInput!) {",
        "find_journeys_mun_criteria(journeysMunCriteria: $journeysMunCriteria) {",
        "journeys, journeys_km, origin_muni, target_muni",
        "} }"
      )
    ),
    variables = list(
      journeysMunCriteria = journeysMunCriteria
    )
  )

  # Enviar la solicitud POST
  response <- httr2::request(graphql_endpoint) |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "User-Agent" = getOption("spanishoddata.user_agent")
    ) |>
    httr2::req_body_json(graphql_query) |>
    httr2::req_perform()

  # Analizar la respuesta
  response_data <- httr2::resp_body_json(response, simplifyVector = TRUE)

  # Comprobar si los datos están vacíos
  if (length(response_data$data[[1]]) == 0) {
    stop("No data found for the given criteria. Please select a different date or province.")
  }

  # Organizar los datos de salida
  od <- tibble::as_tibble(response_data$data[[1]]) |>
    dplyr::select(
      id_origin = .data$origin_muni,
      id_destination = .data$target_muni,
      n_trips = .data$journeys,
      trips_total_length_km = .data$journeys_km
    ) |>
    dplyr::mutate(
      date = lubridate::ymd(date)
    ) |>
    dplyr::relocate(.data$date, .before = id_origin)

  return(od)
}


result <- spod_quick_get_od_by_province(province_code = 38, date = "2020-02-18")
print(result)
