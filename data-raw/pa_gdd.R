library(terra)

prismgrid <- rast("data-raw/gdd/prismgrid.grd")
load("data-raw/gdd/week2017.RDS")

gdd2017 <- setValues(rep(prismgrid, 52), week2017)

pa_naip <- vect("data-raw/naipshp/pa_shpfl_2017/naip_pa_2017_100_m4b.shp")
pa_state <- aggregate(pa_naip) |> project(prismgrid)

pa_prism <- mask(crop(gdd2017, pa_state), pa_state)

writeRaster(pa_prism, "data/pa_gdd2017.tif")

# RESAMPLE TO DEEPBIOSPHERE PREDICTION
dbtemp <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")[[1]]

resample2017 <- terra::project(terra::crop(gdd2017, ext(pa_state)+1), dbtemp,
                                method = "bilinear", mask = TRUE,
                                filename = "data-raw/big/pa_gdd2017_256m.tif",
                               overwrite = TRUE)
