
canary_islands <- c("El Hierro", "La Gomera", "La Palma", "Tenerife", "Gran Canaria", "Lanzarote", "Fuerteventura", "La Graciosa")
codigos <- get_ine_codes("distritos", canary_islands, 2)

df <- read.csv("relacion_ine_zonificacionMitma_canarias.csv", sep = "|", stringsAsFactors = FALSE)


df$distrito_mitma <- trimws(as.character(df$distrito_mitma))

no_encontrados <- setdiff(codigos, df$distrito_mitma)
sobra_en_csv <- setdiff(df$distrito_mitma, codigos)

cat("Códigos de la lista que NO están en el CSV:\n")
print(no_encontrados)

cat("\nCódigos en el CSV que NO están en la lista:\n")
print(sobra_en_csv)

cat("\nCódigos de la lista:\n")
print(codigos)

LP <- c("Las Palmas de Gran Canaria")
result <- get_ine_codes("distritos", LP, 2)
result
