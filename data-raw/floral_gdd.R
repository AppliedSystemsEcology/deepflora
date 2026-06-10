# plot growing degree days (weekly resolution) against plants
library(sf)
library(tidyverse)
# source("R/utils.R")
source("R/getgdd.R")
source("R/get_occs.R")

# gbif data
plants_pa <- read.csv("data-raw/big/plants_pa_2017.csv", sep = "\t")
plants_ny <- read.csv("data-raw/big/plants_ny_2017.csv", sep = "\t")

beeplants <- readRDS("data/beeplants.rds")

plants_fr <- bind_rows(list(pa=plants_pa, ny=plants_ny), .id="state") %>%
  mutate(
    eventDate = as.Date(eventDate),
    week = factor(format(eventDate, "%V"), levels = sprintf("%02d", 1:52))) %>%
  filter(genus %in% beeplants$genus$genus |
           species %in% (beeplants$species %>%
                                  dplyr::filter(source == "Grozinger") %>%
                                  pull(scientificName))) %>%
  filter(year %in% 2016:2020) %>%
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), remove = FALSE)

# load prismgrid
prismgrid <- raster::raster("data-raw/gdd/prismgrid.grd")

plants_prismid <- terra::extract(terra::rast(prismgrid), terra::vect(plants_fr))

plants_gdd <- plants_fr %>% mutate(prismid = plants_prismid$id) %>%
  mutate(gdd = getgddvec(prismid = prismid, year=year, week=week)) %>%
  mutate(gdd2 = getgdd_prismid(prismid = prismid, year=year, week=week)) %>%
  mutate(gdd3 = get_gdd(eventDate, lon = decimalLongitude, lat = decimalLatitude))

saveRDS(plants_gdd, "data/floral_gdd.rds")
