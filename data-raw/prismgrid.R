library(terra)

prismgrid <- terra::rast("data-raw/gdd/prismgrid.grd")

prismdf <- terra::values(prismgrid) %>% as.data.frame() %>%
  rownames_to_column("index") %>% mutate(index = as.numeric(index))

saveRDS(prismdf, "data/prismids.rds")

prismgrid_wgs84 <- terra::project(prismgrid, "epsg:4326", res = res(prismgrid), origin = origin(prismgrid))

terra::writeRaster(prismgrid_wgs84, "data/prismgrid_wgs84.tif")
