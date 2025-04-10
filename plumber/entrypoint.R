#' This file is used for API initialization
#' @description
#' It use the plumber package. More info:
#' https://www.rplumber.io/
#' https://cran.r-project.org/web/packages/plumber/index.html

api <- plumb("plumber/api.R")
api$run(port = 8000)


# # entrypoint.R
# setwd("..") 
# plumber::plumb("plumber/api.R")$run(port = 8000)
