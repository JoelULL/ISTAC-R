con_pg <- dbConnect(
  RPostgres::Postgres(),
  dbname = "duckdb_migracion_test",
  host = "localhost",
  port = 5432,
  user = "rusuario",
  password = "rpass"
)

dbWriteTable(con_pg, "test_manual", data.frame(a = 1:3, b = letters[1:3]), overwrite = TRUE)
dbListTables(con_pg)  