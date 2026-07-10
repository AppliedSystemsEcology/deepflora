# plot growing degree days (weekly resolution) against plants FOR ENTIRE NE
library(sf)
library(tidyverse)
# source("R/utils.R")
source("R/getgdd.R")
source("R/get_occs.R")

# gbif data - combine by species column, scientificName has subsp. that deepbiosphere ignores
plants_pa <- read.csv("data-raw/big/plants_pa_2017.csv", sep = "\t") |>
  select(genus, species, scientificName) |> filter(species != "") |>
  group_by(genus, species) |> summarize(n = n(), .groups = "drop")
plants_ny <- read.csv("data-raw/big/plants_ny_2017.csv", sep = "\t") |>
  select(genus, species, scientificName) |> filter(species != "") |>
  group_by(genus, species) |> summarize(n = n(), .groups = "drop")

beeplants <- readRDS("data/beeplants.rds")

combined_sp <- bind_rows(list(pa=plants_pa, ny=plants_ny), .id="state") |>
  pivot_wider(names_from = state, values_from = n, values_fill = 0) |>
  mutate(
    total = pa+ny,
    pa.pc = 100*pa/total,
    ny.pc = 100*ny/total
  )

combined_sp_flr <- combined_sp |>
  filter(genus %in% beeplants$genus$genus |
           species %in% (beeplants$species |>
                           dplyr::filter(source == "Grozinger") |>
                           pull(scientificName)))

# find 100 most common and evently distributed species
top100_sp_flr <- combined_sp_flr |> # mutate(evenness = (50-abs(50-pa.pc))/50) |>
  filter(pa>=10 & ny>=10) |>
  slice_max(n=100, order_by = total)

# write.csv(top100_sp_flr, "data/top100_sp_flr.csv", row.names = FALSE)

# gbif search only needs to to happen once
top100_gbif <- get_NEgbif(top100_sp_flr$species)

# top100 <- occ_download_get('0049871-260519110011954', path = "./data-raw/big") %>%
#   occ_download_import()

top100 <- occ_download_import(as.download("./data-raw/big/0049871-260519110011954.zip"))

# plot
# library(tidyverse)
# usa <- readRDS("data/spatial/usa.rds")
# gddext <- readRDS("data/gddNEext.rds")
# gbifpts <- sf::st_as_sf(top100, coords = c("decimalLongitude", "decimalLatitude"), crs=crs(usa))
#
# gbifptsplot <- ggplot(st_as_sf(usa)) + geom_sf(fill="yellowgreen", color = "white") +
#   geom_sf(data = sf::st_as_sf(gddext), color = "cyan", fill = NA) +
#   geom_sf(data=gbifpts, size = 0.1, alpha = 0.3) +
#   coord_sf(xlim = ext(gddext)[1:2], ylim = ext(gddext)[3:4])
#
# ggsave("plots/gddpts.png", gbifptsplot, bg="white", height=3, width=4, units="in")

top100sp <- unique(top100$species)

top100_wk <- top100 %>%
  mutate(
    eventDate = as.Date(eventDate),
    week = factor(format(eventDate, "%V"), levels = sprintf("%02d", 1:52))) #%>%
  # mutate(gdd = get_gdd(eventDate, lon = decimalLongitude, lat = decimalLatitude))

gddinfo <- get_gdd(top100_wk$eventDate,
                   lon = top100_wk$decimalLongitude,
                   lat = top100_wk$decimalLatitude,
                   returnPrismid = TRUE)

top100_gdd <- top100_wk %>% bind_cols(gddinfo) %>%
  sf::st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), remove = FALSE)

saveRDS(top100_gdd, "data/top100_gdd.rds")
