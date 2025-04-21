duckdb_to_postgre_migration <- function(duckdb_file_path,
                                        pg_dbname,
                                        pg_host,
                                        pg_port,
                                        pg_user,
                                        pg_password,
                                        delete_duckdb_file = FALSE,
                                        if_exists = c("overwrite", "append", "skip", "error")) {
  #we add a parameter to know what to do with duplicated tables
  if_exists <- match.arg(if_exists)

  con_duckdb <- dbConnect(duckdb(), dbdir = duckdb_file_path)
  tables <- dbListTables(con_duckdb)

  if (length(tables) == 0) {
    dbDisconnect(con_duckdb)
    stop("No table(s) detected in the DuckDB file.")
  }

  con_postgres <- dbConnect(
    RPostgres::Postgres(),
    dbname = pg_dbname,
    host = pg_host,
    port = pg_port,
    user = pg_user,
    password = pg_password
  )

  message("Migrating DuckDB to PostgreSQL...")

  for (table_name in tables) {
    message("Processing table: ", table_name)

    if (DBI::dbExistsTable(con_postgres, table_name)) {
      if (if_exists == "overwrite") {
        DBI::dbRemoveTable(con_postgres, table_name)
      } else if (if_exists == "skip") {
        message("Skipping table ", table_name, " because it already exists.")
        next
      } else if (if_exists == "error") {
        stop("Table '", table_name, "' already exists in PostgreSQL.")
      }
    }

    data <- DBI::dbReadTable(con_duckdb, table_name)

    DBI::dbWriteTable(
      con_postgres,
      name = table_name,
      value = data,
      overwrite = (if_exists == "overwrite"),
      append = (if_exists == "append"),
      row.names = FALSE
    )
  }

  DBI::dbDisconnect(con_duckdb)
  DBI::dbDisconnect(con_postgres)

  message("Migration completed successfully.")

  if (delete_duckdb_file) {
    file.remove(duckdb_file_path)
  }
}
