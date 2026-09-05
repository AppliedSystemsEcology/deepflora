library(terra)
library(tidyverse)
library(tidyterra)
library(gganimate)

source("R/mix_mods.R")

plants <- read.csv("data-raw/rare-plants.csv")
raredir <- "data/rare"
rarefiles <- list.files(raredir)
rareplants <- gsub("_", " ", gsub(".tif","",rarefiles))

raretifs <- lapply(file.path(raredir,rarefiles), rast) |> setNames(rareplants)

phenovis <- read.csv("data/pheno_sp.csv")

# gdd spatial data

# gdd_15yrs <- rast("data/NE_gdd15yrs.tif")
# tiles_gdd <- terra::project(terra::crop(gdd_15yrs,
#                                         terra::project(
#                                           ext(raretifs[[1]])+4000,  # crop to tif ext
#                                           crs(raretifs[[1]]),    # match proj, from
#                                           crs(gdd_15yrs))        # match proj, to
#                                         ),
#                             raretifs[[1]],
#                             method = "bilinear", mask = TRUE) |>
#   terra::mask(raretifs[[1]],
#               filename = "data-raw/big/raretiles_gdd.tif",
#               overwrite = TRUE)

tiles_gdd <- rast("data-raw/big/raretiles_gdd.tif")
# add a 0 raster at the beginning of the gdd time series to subtract from
tiles_gdd0 <- tiles_gdd[[1]]*0

# make predictions
for(i in seq_along(rareplants)){

  plot_i <- ggplot() + geom_spatraster(data=raretifs[[rareplants[i]]]) +
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
      title = rareplants[i]
    )

  pheno.i <- phenovis %>% filter(scientific_name == plants$species[i] & trait == "flower")

  # make a container for distribution info
  gdd_mod.i <- list(
    mu = mean(pheno.i$gdd),
    sigma = sd(pheno.i$gdd),
    lambda = 1,
    x = seq(0,5000, by = 100)
  )

  gdd_dist.i <- make_dist_mix(gdd_mod.i, 50)  # make the distribution prediction across gdd

  # apply pnorm function to stack of gdd rasters
  gdd_plant_cdf.i <- terra::app(tiles_gdd, pnorm, mean = gdd_mod.i$mu, sd = gdd_mod.i$sigma)

  gdd_plant_0cdf.i <- c(tiles_gdd0, gdd_plant_cdf.i)

  # find difference in cumulative probability between weeks
  plant0_flrprb <- terra::diff(gdd_plant_0cdf.i,
                               filename = paste0("data-raw/big/rare-flrprb/flrpb_",rarefiles[i]),
                               overwrite = TRUE)

  # plot a gif
  gdd_anim.i <- ggplot() +
    geom_spatraster(data = plant0_flrprb) +
    scale_fill_viridis_c(
      option = "magma",
      na.value = "transparent"
    ) +
    transition_manual(lyr) +
    theme_bw() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank()
    ) +
    labs(
      title = paste0(rareplants[i], " bloom probability (2006-2020): Week {current_frame}"),
      fill = ""
    )

  gganimate::anim_save(filename = paste0("plots/rare_plants/flrpb_",gsub(".tif","",rarefiles[i]),".gif"),
                       width = 8, height = 4,
                       gganimate::animate(gdd_anim.i, duration = 12, renderer = gifski_renderer())
  )

  # multiply sp distribution with gdd (spatiotemporal bloom probability)
  plant_flrprb <- plant0_flrprb * raretifs[[rareplants[i]]]

  writeRaster(plant_flrprb, filename = paste0("data-raw/big/rare-flrprb/plantflrpb_",rarefiles[i]), overwrite = TRUE)

  # plot a gif of spatiotemporal bloom prob
  plant_gdd_anim.i <- ggplot() +
    geom_spatraster(data = plant_flrprb) +
    scale_fill_viridis_c(
      option = "turbo",
      na.value = "transparent"
    ) +
    transition_manual(lyr) +
    theme_bw() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank()
    ) +
    labs(
      title = paste0(rareplants[i], " spatial and bloom probability (2006-2020): Week {current_frame}"),
      fill = ""
    )

  gganimate::anim_save(filename = paste0("plots/rare_plants/phenomap_",gsub(".tif","",rarefiles[i]),".gif"),
                       width = 8, height = 4,
                       gganimate::animate(plant_gdd_anim.i, duration = 12, renderer = gifski_renderer())
  )

  pheno_plot.i <- ggplot(pheno.i, aes(x=gdd)) +
    geom_histogram(aes(fill = trait), binwidth = 50) +
    coord_cartesian(xlim=c(0,5000)) + labs(title = plants$species[i]) +
    geom_line(data = gdd_dist.i,
              mapping = aes(x = x, y = y, color = dist), linewidth = 1.5) +
    scale_color_manual(
      name = "Flowering curve",
      values = c("turquoise4")
      ) +
    egg::theme_article()

  ggsave(paste0("plots/rare_plants/phenomod_",gsub(".tif","",rarefiles[i]),".png"),
         pheno_plot.i, width = 8, height = 4, units = "in", bg = "white", dpi = 300)

}
