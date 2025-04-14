#' This function migrates a duckdb table to PostgreSQL
#' @description
#' Migrates all DuckDB tables to PostgreSQL
#' via full-table overwrites.
#' @param duckdb_file_path filtered data duckdb file
#' @param pg_dbname postgre data base name
#' @param pg_host postgre database host
#' @param pg_port postgre database port
#' @param pg_user postgre database user
#' @param pg_password postgre database password
#' @param delete_duckdb_file boolean variable. Allows user to eliminate
#'   the DuckDB file generated.

duckdb_to_postgre_migration <- function(duckdb_file_path,
                                        pg_dbname,
                                        pg_host,
                                        pg_port,
                                        pg_user,
                                        pg_password,
                                        delete_duckdb_file ) {

  con_duckdb <- dbConnect(duckdb(), dbdir = duckdb_file_path)
  tables <- dbListTables(con_duckdb)

  if (length(tables) == 0) {
    dbDisconnect(con_duckdb, silent = TRUE)
    stop("No table/s detected")
  }

  con_postgres <- dbConnect(
    RPostgres::Postgres(),
    dbname = pg_dbname,
    host = pg_host,
    port = pg_port,
    user = pg_user,
    password = pg_password
  )

  print("Migrating DuckDB to PostgreSQL...")

  for (table_name in tables) {
    print(paste("migrating table:", table_name))

    data <- dbReadTable(con_duckdb, table_name)

    dbWriteTable(con_postgres, table_name, data, overwrite = TRUE, row.names = FALSE)
  }

  dbDisconnect(con_duckdb)
  dbDisconnect(con_postgres)

  print("Migration success")

  # If true, deletes the duckdb file generated
  if (delete_duckdb_file) {
    file.remove(duckdb_file_path)
  }

}

# #verification
# con <- dbConnect(
#   RPostgres::Postgres(),
#   dbname = "duckdb_migracion",
#   host = "localhost",
#   port = 5432,
#   user = "rusuario",
#   password = "rpass"
# )

# dbListTables(con)
# dbDisconnect(con)


# #check if .duckdb has data

# con_duck <- dbConnect(duckdb(), dbdir = "data/data_test.duckdb")
# dbListTables(con_duck)

# dbReadTable(con_duck, dbListTables(con_duck)[1])
# dbDisconnect(con_duck)

# ## how many tables .duckdbfile has
# con <- dbConnect(duckdb::duckdb(), dbdir = "data/data_test.duckdb")

# tables <- dbListTables(con)

# cat("El archivo contiene", length(tables), "tabla(s).\n")

# print(tables)

# dbDisconnect(con)

# ##in-code test
# duckdb_to_postgre_migration(
#   duckdb_file_path = "data/data_test.duckdb",
#   pg_dbname = "duckdb_migracion",
#   pg_host = "localhost",
#   pg_port = 5432,
#   pg_user = "rusuario",
#   pg_password = "rpass",
#   delete_duckdb_file = TRUE
# )

# con <- dbConnect(
#   RPostgres::Postgres(),
#   dbname = "duckdb_migracion",
#   host = "localhost",
#   port = 5432,
#   user = "rusuario",
#   password = "rpass"
# )

# dbListTables(con)
# data <- dbReadTable(con, "filtered_table")
# print(head(data))
# dbDisconnect(con)
