library(terra)

prismgrid <- rast("data-raw/gdd/prismgrid.grd")
pa_naip <- vect("data-raw/naipshp/pa_shpfl_2017/naip_pa_2017_100_m4b.shp")
pa_state <- aggregate(pa_naip) |> project(prismgrid)

# growing degree days 2017
load("data-raw/gdd/week2017.RDS")

gdd2017 <- setValues(rep(prismgrid, 52), week2017)

pa_prism_2017 <- mask(crop(gdd2017, pa_state), pa_state)

writeRaster(pa_prism_2017, "data/pa_gdd2017.tif")

# growing degree days 15 year average
week15 <- readRDS("data-raw/gdd/week.mean15.RDS")

gdd.15 <- setValues(rep(prismgrid, 52), week15)

pa_gdd_15yrs <- mask(crop(gdd.15, pa_state), pa_state)

writeRaster(pa_gdd_15yrs, "data/pa_gdd15yrs.tif")
writeRaster(gdd.15, "data/NE_gdd15yrs.tif")

# RESAMPLE TO DEEPBIOSPHERE PREDICTION
dbtemp <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")[[1]]

resample2017 <- terra::project(terra::crop(gdd2017, ext(pa_state)+1), dbtemp,
                                method = "bilinear", mask = TRUE,
                                filename = "data-raw/big/pa_gdd2017_256m.tif",
                               overwrite = TRUE)
