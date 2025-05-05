
get_ine_codes <- function(option, zones, ver) {
    ine_codes <- c()

    zone_codes <- spod_get_zones(option, ver = ver)
    zone_codes_wgs84 <- zone_codes |>
        sf::st_simplify(dTolerance = 200) |>
        sf::st_transform(4326)
        
    for (zone in zones) {
            option_zones <- zonebuilder::zb_zone(zone)
            insert_option_zones <- zone_codes_wgs84[option_zones, ]

            #id <- unique(unlist(strsplit(as.character(insert_option_zones$id), "; ")))
            id <- unlist(as.character(insert_option_zones$id))
            ine_codes <- unique(c(ine_codes, id))
    }

    if (length(ine_codes) == 0) {
        stop("No id codes availables!\n")
    }
    ine_codes
}

# canary_islands <- c("El Hierro", "La Gomera", "La Palma", "Tenerife", "Gran Canaria", "Lanzarote", "Fuerteventura", "La Graciosa")
# result <- get_ine_codes("gau", canary_islands, 2)
# result