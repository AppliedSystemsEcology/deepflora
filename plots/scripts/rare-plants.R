library(terra)
library(tidyverse)
library(tidyterra)

plants <- read.csv("data-raw/rare-plants.csv")

dfpa <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")
gdd <- readRDS("data/top100_gdd_thin.rds")
mixm <- readRDS("data/results/mixmods_flr100_thin.rds")

plants_in <- plants[which(plants$species %in% names(dfpa)),]

plants$species[!(plants$species %in% names(dfpa))]   # Solidago speciosa is missing (not in PA)

plants$species[plants$species %in% names(mixm)]

for(i in seq_len(nrow(plants_in))){

  plot_i <- ggplot() + geom_spatraster(data=dfpa[[plants_in$species[i]]]) +
    scale_fill_viridis_c(
      option = "rocket",
      na.value = "transparent"
    ) +
    theme_bw() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank()
    ) +
    labs(
      fill = "",
      title = plants_in$species[i]
    )

  ggsave(paste0("plots/rare_plants/",gsub(" ", "_", plants_in$species[i]),".png"),
         plot_i, width = 4, height = 2.5, units = "in", bg = "white", dpi = 300)

}


