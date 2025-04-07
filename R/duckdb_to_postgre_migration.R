#
#
#
#
#
# This function migrates a duckdb table to PostgreSQL 
duckdb_to_postgre_migration <- function(duckdb_file_path,
                                        pg_dbname,
                                        pg_host,
                                        pg_port,
                                        pg_user,
                                        pg_password ) {
  
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
}

#verification
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "duckdb_migracion",
  host = "localhost",
  port = 5432,
  user = "rusuario",
  password = "rpass"
)

dbListTables(con)
dbDisconnect(con)
