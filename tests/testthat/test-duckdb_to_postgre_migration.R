

pg_dbname <- "duckdb_migracion_test"
pg_host <- "localhost"
pg_port <- 5432
pg_user <- "rusuario"
pg_password <- "rpass"

test_that("duckdb_to_postgre_migration migrates a table correctly", {

  duckdb_path <- tempfile(fileext = ".duckdb")
  con_duckdb <- dbConnect(duckdb(), dbdir = duckdb_path)
  
  test_data <- data.frame(
    id = 1:3,
    name = c("Alice", "Bob", "Charlie"),
    score = c(90, 85, 88)
  )
  dbWriteTable(con_duckdb, "test_table", test_data)
  dbDisconnect(con_duckdb)


  duckdb_to_postgre_migration(
    duckdb_file_path = duckdb_path,
    pg_dbname = pg_dbname,
    pg_host = pg_host,
    pg_port = pg_port,
    pg_user = pg_user,
    pg_password = pg_password,
    delete_duckdb_file = FALSE
  )

 
  con_pg <- dbConnect(
    RPostgres::Postgres(),
    dbname = pg_dbname,
    host = pg_host,
    port = pg_port,
    user = pg_user,
    password = pg_password
  )

  tables_pg <- dbListTables(con_pg)
  expect_true("test_table" %in% tables_pg)

  data_pg <- dbReadTable(con_pg, "test_table")
  expect_equal(data_pg, test_data)

  # Cleanup
  dbExecute(con_pg, "DROP TABLE IF EXISTS test_table")
  dbDisconnect(con_pg)
  file.remove(duckdb_path)
})

test_that("function throws error when DuckDB has no tables", {
  duckdb_path <- tempfile(fileext = ".duckdb")
  con_duckdb <- dbConnect(duckdb(), dbdir = duckdb_path)
  dbDisconnect(con_duckdb)

  expect_error(
    duckdb_to_postgre_migration(
      duckdb_file_path = duckdb_path,
      pg_dbname = pg_dbname,
      pg_host = pg_host,
      pg_port = pg_port,
      pg_user = pg_user,
      pg_password = pg_password,
      delete_duckdb_file = FALSE
    ),
    "No table/s detected"
  )

  file.remove(duckdb_path)
})

test_that("duckdb file is deleted when delete_duckdb_file = TRUE", {
  duckdb_path <- tempfile(fileext = ".duckdb")
  con <- dbConnect(duckdb(), dbdir = duckdb_path)
  dbWriteTable(con, "table_to_delete", data.frame(x = 1:5))
  dbDisconnect(con)

  expect_true(file.exists(duckdb_path))

  duckdb_to_postgre_migration(
    duckdb_file_path = duckdb_path,
    pg_dbname = pg_dbname,
    pg_host = pg_host,
    pg_port = pg_port,
    pg_user = pg_user,
    pg_password = pg_password,
    delete_duckdb_file = TRUE
  )

  expect_false(file.exists(duckdb_path))

  # Cleanup
  con_pg <- dbConnect(RPostgres::Postgres(),
                      dbname = pg_dbname,
                      host = pg_host,
                      port = pg_port,
                      user = pg_user,
                      password = pg_password)
  dbExecute(con_pg, "DROP TABLE IF EXISTS table_to_delete")
  dbDisconnect(con_pg)
})

test_that("multiple tables are migrated correctly", {
  duckdb_path <- tempfile(fileext = ".duckdb")
  con <- dbConnect(duckdb(), dbdir = duckdb_path)

  data1 <- data.frame(id = 1:2, value = c("a", "b"))
  data2 <- data.frame(score = c(100, 90), passed = c(TRUE, FALSE))

  dbWriteTable(con, "table_one", data1)
  dbWriteTable(con, "table_two", data2)
  dbDisconnect(con)

  duckdb_to_postgre_migration(
    duckdb_file_path = duckdb_path,
    pg_dbname = pg_dbname,
    pg_host = pg_host,
    pg_port = pg_port,
    pg_user = pg_user,
    pg_password = pg_password,
    delete_duckdb_file = FALSE
  )

  con_pg <- dbConnect(RPostgres::Postgres(),
                      dbname = pg_dbname,
                      host = pg_host,
                      port = pg_port,
                      user = pg_user,
                      password = pg_password)

  expect_true("table_one" %in% dbListTables(con_pg))
  expect_true("table_two" %in% dbListTables(con_pg))

  expect_equal(dbReadTable(con_pg, "table_one"), data1)
  expect_equal(dbReadTable(con_pg, "table_two"), data2)

  dbExecute(con_pg, "DROP TABLE IF EXISTS table_one")
  dbExecute(con_pg, "DROP TABLE IF EXISTS table_two")
  dbDisconnect(con_pg)
  file.remove(duckdb_path)
})
