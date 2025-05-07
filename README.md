# MITMA-ISTAC-R

## Descripción

**MITMA-ISTAC-R** provee funciones para la descarga parametrizada de los datos de movilidad proporcionados por el Ministerio de Transportes y Movilidad Sostenible y su posterior migración a bases de datos PostgreSQL. Se utiliza el paquete R [Spanishoddata](https://github.com/rOpenSpain/spanishoddata) que permite el acceso y la descarga de los datos del Ministerio.

Para más información acerca del funcionamiento de las funciones del paquete de Spanishoddata se recomienda leer la [documentación asociada](https://ropenspain.github.io/spanishoddata/).

## Entrada

| Nombre                     | Descripción    |
| -------------------------- | -------------- |
| fichero_configuracion.JSON | Fichero con los parámetros descarga y filtrado y la configuración de la base de datos de PostgreSQL receptora. |


## Salida

Ficheros de salida o tablas.

| Nombre   | Descripción    |
| -------- | -------------- |
| salida-1 | some-text-here |
| salida-2 | some-text-here |

## Parámetros

| Parámetro   | Descripción    |
| ----------- | -------------- |
| parámetro-1 | some-text-here |
| parámetro-2 | some-text-here |

some-text-here

## Flujo

 El flujo sigue los siguientes pasos:
 
 1. Descarga en un directorio temporal los datos solicitados a través de la librería de Spanishoddata. 
 
 2. Realiza el filtrado mediante los parámetros deseados.
 
 3. Obtención de las tablas resultados en un fichero DuckDB. 
 
 4. Eliminación del directorio temporal para liberar espacio. 
 
 5. Migración de los datos a PostgreSQL.

### Esquema de flujo

```mermaid
graph TD
    A[Recibe fichero JSON con parámetros de filtrado y descarga y la configuración de la BBDD PostgreSQL] -- json_data_downloand_and_migrate(fichero_configuracion.JSON)  --> B[Se crea un directorio temporal para almacenar los datos sin filtrar]
    B -- create_temp_dir() --> C[Se comprueba si hay procesos huérfanos de DuckDB]
    C -- close_orphan_duckdb_process() --> D[Descarga parametrizada en base a los filtros]
    D -- download_data_filtered_v2(parametros de filtrado y descarga) --> E[Se obtiene un archivo DuckDB con las tablas resultado y se elimina el directorio temporal anterior]
    E -- duckdb_to_postgre_migration(dirección de archivo DuckDB y parámetros de la BBDD de PostgreSQL)--> F[Migración de las tablas a PostgreSQL]
```


## Requisitos

A continuación se desglosan las librerías utilizadas:

| Software / Librería | Versión                |
| ------------------- | ---------------------- |
| languageserver      | Más reciente           |
| lintr               | Más reciente           |
| styler              | Más reciente           |
| testthat            | Más reciente           |
| mockery             | Más reciente           |
| plumber             | Más reciente           |
| spanishoddata       | Más reciente           |
| dplyr               | Más reciente           |
| DBI                 | Más reciente           |
| uuid                | Más reciente           |
| RPostgres           | Más reciente           |
| duckdb              | Más reciente           |
| jsonlite            | Más reciente           |
| here                | Más reciente           |
| zonebuilder         | Más reciente           |
| tmaptools           | Más reciente           |
| sf                  | Más reciente           |


## Observaciones

some-text-here

## Responsable

* Responsable del desarrollo: _Joel Aday Dorta Hernández_
* Técnico estadístico responsable: _nombre-completo_