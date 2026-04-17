library(terra)

arraynum <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
naipdirs <- list.dirs("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/pa_250/256m_2017_-1_initial_7/",
                      full.names = TRUE)

array_dir <- naipdirs[arraynum]

array_tifs <- list.files(array_dir, pattern = "*raw.tif", full.names = TRUE)

terraOptions(memfrac = 0.6, tempdir = "/scratch/kbl5733/tmp", threads = 8)

out.vrt <- paste0("/storage/home/kbl5733/gstorage/data/deepflora/maps/vrt/",basename(array_dir),".vrt")

pa_vrt <- terra::vrt(array_tifs, filename = out.vrt)

out.mosaic <- paste0("/storage/home/kbl5733/gstorage/data/deepflora/maps/mosaic/",basename(array_dir),".tif")

terra::mosaic(pa_vrt,
              filename = out.mosaic,
              overwrite = TRUE
              )
