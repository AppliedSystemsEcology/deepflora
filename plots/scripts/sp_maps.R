library(terra)
library(tidyverse)
library(tidyterra)
library(rnaturalearth)
library(gganimate)

padf <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")

# Cercis canadensis
ccdf <- padf[["Cercis canadensis"]]
cc <- readRDS("data/top100_gdd_thin.rds") |> filter(species == "Cercis canadensis")
cc.mix <- readRDS("data/results/mixmods_flr100_thin.rds")[["Cercis canadensis"]]

# use distribution 1
cc.d <- 1

cc.mu <- cc.mix$mu[cc.d]
cc.sigma <- cc.mix$sigma[cc.d]

pa_gdd <- rast("data-raw/big/pa_gdd2017_256m.tif")

# apply pnorm function to stack of gdd rasters
cc_gdd_cdf <- terra::app(pa_gdd, pnorm, mean = cc.mu, sd = cc.sigma)

# add a 0 raster at the beginning of the gdd time series to substract from
cc_gdd_0 <- pa_gdd[[1]]*0
cc_gdd_0cdf <- c(pa_gdd_0, pa_gdd_cdf)

# find difference in cumulative probability between weeks
cc_flrpb <- terra::diff(cc_gdd_0cdf, filename = "data-raw/big/flrpb_Ccanadensis.tif")

# plot a gif
cc_gdd_anim <- ggplot() +
  geom_spatraster(data = cc_flrpb) +
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
    title = "Cercis canadensis bloom probability (2017): {current_frame}",
    fill = ""
  )

gganimate::anim_save(filename = "plots/flrpb_Ccanadensis.gif",
                     gganimate::animate(cc_gdd_anim, duration = 12, renderer = gifski_renderer())
)

# multiply sp distribution with gdd (spatiotemporal bloom probability)
cc_stbp <- cc_flrpb * ccdf

# plot a gif of spatiotemporal bloom prob
cc_bloom_anim <- ggplot() +
  geom_spatraster(data = cc_stbp) +
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
    title = "Cercis canadensis bloom probability (2017): {current_frame}",
    fill = ""
  )

gganimate::anim_save(filename = "plots/stflrpb_Ccanadensis.gif",
                     gganimate::animate(cc_bloom_anim, duration = 12, renderer = gifski_renderer())
)
