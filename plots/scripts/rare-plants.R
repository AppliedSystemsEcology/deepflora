library(terra)

plants <- read.csv("data-raw/rare-plants.csv")

dfpa <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")
gdd <- readRDS("data/top100_gdd_thin.rds")
mixm <- readRDS("data/results/mixmods_flr100_thin.rds")

plants_in <- plants[which(plants$species %in% names(dfpa)),]

plants$species[!(plants$species %in% names(dfpa))]   # Solidago speciosa is missing (not in PA)

plants$species[plants$species %in% names(mixm)]

for(i in seq_len(nrow(plants_in))){
  terra::plot(dfpa[[plants_in$species[i]]])
}


