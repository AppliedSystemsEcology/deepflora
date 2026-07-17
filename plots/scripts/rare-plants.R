library(terra)
library(tidyverse)
library(tidyterra)

plants <- read.csv("data-raw/rare-plants.csv")

dfpa <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")
dfny <- rast("data-raw/big/ny_2017_merge_mosaic.tif")
gdd <- readRDS("data/top100_gdd_thin.rds")
# mixm <- readRDS("data/results/mixmods_flr100_thin.rds")
phenovis <- read.csv("data/pheno_sp.csv")

plants_in <- plants[which(plants$species %in% names(dfpa)),]

plants$species[!(plants$species %in% names(dfpa))]   # Solidago speciosa is missing (not in PA)

# plants$species[plants$species %in% names(mixm)]

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

  ggsave(paste0("plots/rare_plants/map_",gsub(" ", "_", plants_in$species[i]),".png"),
         plot_i, width = 8, height = 4, units = "in", bg = "white", dpi = 300)

}

plot_ny <- ggplot() +
  geom_spatraster(data=dfny[["Solidago speciosa"]]) +
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
    title = "Solidago speciosa"
  )

ggsave(paste0("plots/rare_plants/map_Solidago_speciosa.png"),
       plot_ny, width = 8, height = 4, units = "in", bg = "white", dpi = 300)

# phenovision plots
pheno_sp <- unique(phenovis$scientific_name)

plants_in_pheno <- pheno_sp[which(plants$species %in% pheno_sp)]

for(i in seq_len(nrow(plants))){
  pheno.i <- phenovis %>% filter(scientific_name == plants$species[i] & trait == "flower")

  pheno_plot.i <- ggplot(pheno.i, aes(x=gdd)) +
    geom_histogram(aes(fill = trait), binwidth = 50) +
    coord_cartesian(xlim=c(0,5000)) + labs(title = plants$species[i]) +
    egg::theme_article()

  ggsave(paste0("plots/rare_plants/pheno_",gsub(" ", "_", plants$species[i]),".png"),
         pheno_plot.i, width = 8, height = 4, units = "in", bg = "white", dpi = 300)

}
