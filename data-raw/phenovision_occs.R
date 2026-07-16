library(arrow)
library(tidyverse)
library(sf)

NEext <- readRDS("data/gddNEext.rds")
phenovis <- open_dataset("data-raw/big/phenovision")
sp <-read.csv("data/combined_sp.csv")
ext(NEext)
source("R/getgdd.R")

NEoccs <- phenovis %>% collect() %>%
  filter(
    latitude < ext(NEext)$ymax,
    latitude > ext(NEext)$ymin,
    longitude < ext(NEext)$xmax,
    longitude > ext(NEext)$xmin,
    year >= 2016, year <= 2020,
    coordinate_uncertainty_meters <= 1000
  )

NEoccs <- NEoccs %>% filter(scientific_name %in% sp$species) %>%
  select(verbatim_date, day_of_year, year, latitude, longitude, coordinate_uncertainty_meters,
         family, genus, scientific_name, trait) %>%
  mutate(
    eventDate = as.Date(verbatim_date),
    week = factor(format(eventDate, "%V"), levels = sprintf("%02d", 1:52)))

gddinfo <- get_gdd(NEoccs$eventDate,
                   lon = NEoccs$longitude,
                   lat = NEoccs$latitude,
                   returnPrismid = TRUE)

NEoccs_us <- NEoccs %>% bind_cols(gddinfo) %>% filter(!is.na(gdd))

write.csv(NEoccs_us, "data/pheno_sp.csv", row.names = FALSE)
