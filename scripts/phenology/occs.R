# library(spocc)
library(rinat)
# library(geodata)

# gadm("USA", level = 1, "data/spatial")

pa <- readRDS("data/spatial/gadm/gadm41_USA_1_pk.rds") |>
  sf::st_as_sf() |>
  dplyr::filter(NAME_1=="Pennsylvania")

get_inat_plants <- function(year, month, state){
  rinat::get_inat_obs(
    taxon_id = 47126,
    quality = "research",
    geo = TRUE,
    year = year,
    month = month,
    bounds = state,
    maxresults = 10000
  )
}

pa_occ <- list()
years <- 2012:2022
months <- 1:12

for(i in seq_along(years)){
  pa_occ[[i]] <- list()
  for(j in seq_along(months)){
    pa_occ[[i]][[j]] <- get_inat_plants(year = years[i], month = months[j], state = pa)
  }
}
