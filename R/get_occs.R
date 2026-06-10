library(tidyverse)
library(rgbif)

# usethis::edit_r_environ()

gddNEext <- readRDS("data/gddNEext.rds") %>%
  sf::st_geometry() %>%
  sf::st_as_text() %>%
  wk::wkt() %>%
  wk::wk_orient()



species2usagekey <- function(species){
  name_backbone_checklist(species) %>% # match to backbone
    filter(!matchType == "NONE") %>% # get matched names
    pull(usageKey)
}

get_NEgbif <- function(species, ...){
  usagekey <- species2usagekey(species)

  rgbif::occ_download(
    type = "and",
    pred_in("taxonKey", usagekey),
    pred("basisOfRecord", "HUMAN_OBSERVATION"),
    pred_lt("coordinateUncertaintyInMeters",120),
    pred_gte("coordinateUncertaintyInMeters",0),
    pred("hasCoordinate",TRUE),
    pred("hasGeospatialIssue",FALSE),
    pred("occurrenceStatus","PRESENT"),
    pred_gte("year", 2016),
    pred_lte("year", 2020),
    pred_within(gddNEext),
    pred("gadm","USA"),
    format = "DWCA",
    ...
  )
}

# replicate deepbiosphere search
# basegbifopts <- list(
#   basisOfRecord = "HUMAN_OBSERVATION",
#   coordinateUncertaintyInMeters = "0,120",
#   hasCoordinate = TRUE,
#   hasGeospatialIssue = FALSE,
#   occurrenceStatus = "PRESENT",
#   # taxonKey = 6,
#   # gadmGid = "USA.39_1",
#   eventDate = "2012,2022"
# )
#
# spocc::occ(
#   from = "gbif",
#   geometry = gddNEext,
#   gbifopts = c(basegbifopts, scientificName = species),
#   ...
# )
