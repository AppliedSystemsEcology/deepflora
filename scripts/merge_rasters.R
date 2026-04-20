library(terra)
# THIS IS VERY VERY SLOW AND DOESN'T ACCOUNT FOR DIFFERENT CRS

pa_raw <- list.files("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/pa_250/256m_2017_-1_initial_7/",
           pattern = "*raw.tif", recursive = TRUE, full.names = TRUE)

terraOptions(memfrac = 0.6, tempdir = "/scratch/kbl5733/tmp", threads = 8)

pa_sprc <- terra::sprc(pa_raw)

terra::mosaic(pa_sprc,
              filename = "/storage/home/kbl5733/gstorage/data/deepflora/maps/pa_mosaic.tif",
              overwrite = TRUE
              )
