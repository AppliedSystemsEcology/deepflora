library(terra)

pa_raw <- list.files("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/pa_250/256m_2017_-1_initial_7/",
           pattern = "*raw.tif", recursive = TRUE, full.names = TRUE)

pa_sprc <- terra::sprc(pa_raw)

pa_mosaic <- terra::mosaic(pa_sprc)

terra::writeRaster(pa_mosaic, "/storage/home/kbl5733/gstorage/data/deepflora/maps/pa_mosaic.tif")
