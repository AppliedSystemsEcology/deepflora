library(terra)
# final merge

pa_tiles <- list.files("/storage/home/kbl5733/gstorage/data/deepflora/maps/mosaic",
           pattern = "*.tif", full.names = TRUE)

pa_sprc <- terra::sprc(pa_tiles)

terra::mosaic(pa_sprc,
              filename = "/storage/home/kbl5733/gstorage/data/deepflora/maps/pa_mosaic.tif",
              overwrite = TRUE
              )
