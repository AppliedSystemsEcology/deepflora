library(mixtools)
library(tidyverse)

source("R/mix_mods.R")

plants_gdd <- readRDS("data/floral_gdd.rds") |> sf::st_drop_geometry()

# all plants
fromtop <- names(sort(table(plants_gdd$scientificName), decreasing = TRUE))

mixmods <- list()
for(g in seq_along(fromtop)){
  sp.g <- plants_gdd %>%
    dplyr::filter(scientificName == fromtop[g]) %>%
    dplyr::filter(!is.na(gdd))

  mixmods[[fromtop[g]]] <- tryCatch(fitmix(sp.g$gdd),
                                    error = function(e) e)

}

saveRDS(mixmods, file = "data/flor_mixmods.rds")
