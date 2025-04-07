# Check if library must be here
# library(plumber)
#
# This file is used for API initialization

api <- plumb("plumber/api.R")
api$run(port = 8000)


# # entrypoint.R
# setwd("..") 
# plumber::plumb("plumber/api.R")$run(port = 8000)
