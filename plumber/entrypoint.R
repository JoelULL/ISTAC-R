# Check if library must be here
# library(plumber)
#
# This file is used for API initialization

api <- plumb("plumber/api.R")
api$run(port = 8000)
