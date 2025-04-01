source("R/download_data_filtered.R")

test_that("download_data_filtered lanza un error para tipos no reconocidos", {
  # Ejecutar la función con un tipo inválido
  codes <- c("38", "35")
  result <- download_data_filtered(
    zones = "muni",
    start_date = "2022-01-01",
    end_date = "2022-01-02",
    type = "ok", # Tipo no reconocido
    param_codes = codes
  )
  
  # Verificar que el resultado indica error
  expect_equal(result$status, "error")
  expect_match(
    result$message,
    "Assertion on 'type' failed: Must be element of set {'od','origin-destination','os','overnight_stays','nt','number_of_trips'}, but is 'ok'."
  )
})

