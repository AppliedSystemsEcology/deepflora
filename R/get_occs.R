library(spocc)
library(rgbif)
library(tidyverse)

# replicate deepbiosphere search
basegbifopts <- list(
  basisOfRecord = "HUMAN_OBSERVATION",
  coordinateUncertaintyInMeters = "0,120",
  hasCoordinate = TRUE,
  hasGeospatialIssue = FALSE,
  occurrenceStatus = "PRESENT",
  # taxonKey = 6,
  # gadmGid = "USA.39_1",
  eventDate = "2012,2022",
  limit = 1000000
)

