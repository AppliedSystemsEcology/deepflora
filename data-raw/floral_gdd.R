# plot growing degree days (weekly resolution) against plants
library(sf)
library(tidyverse)
source("R/utils.R")

# gbif data
plants_pa <- read.csv("data/big/plants_gbif_pa.csv",sep="\t")
beeplants <- readRDS("data/beeplants.rds")

plants_pa_fr <- plants_pa %>%
  mutate(
    eventDate = as.Date(eventDate),
    week = factor(format(eventDate, "%V"), levels = sprintf("%02d", 1:52))) %>%
  filter(genus %in% beeplants$genus$genus |
           species %in% (beeplants$species %>%
                                  dplyr::filter(source == "Grozinger") %>%
                                  pull(scientificName))) %>%
  filter(year %in% 2016:2020) %>%
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"))

# load prismgrid
prismgrid <- raster::raster("data/prismgrid.grd")

plants_pa_prismid <- terra::extract(terra::rast(prismgrid), terra::vect(plants_pa_fr))

plants_pa_gdd <- plants_pa_fr %>% mutate(prismid = plants_pa_prismid$id) %>%
  mutate(gdd = getgddvec(prismid = prismid, year=year, week=week))

saveRDS(plants_pa_gdd, "data/pa_floral_gdd.rds")
