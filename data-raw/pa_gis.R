library(terra)

prismgrid <- rast("data/prismgrid.grd")
load("data-raw/gdd/week2017.RDS")

gdd2017 <- setValues(rep(prismgrid, 52), week2017)

pa_naip <- vect("data-raw/naipshp/naip_pa_2017_100_m4b.shp")
pa_state <- aggregate(pa_naip) |> project(prismgrid)

pa_prism <- mask(crop(gdd2017, pa_state), pa_state)

writeRaster(pa_prism, "data/pa_gdd2017.tif")
