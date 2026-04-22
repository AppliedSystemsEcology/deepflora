library(terra)

arraynum <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
naipdirs <- list.dirs("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/pa_250/256m_2017_-1_initial_7",
                      recursive = FALSE, full.names = TRUE)

array_dir <- naipdirs[arraynum]

array_tifs <- list.files(array_dir, pattern = "*raw.tif", full.names = TRUE)


# make a template raster from extent for output
naip_pa <-vect("/storage/home/kbl5733/work/github/deepflora/data/extents/naip_pa_albers.geojson") # get the NAIP full PA extent vector
naip_extent <- ext(naip_pa) + 1
temp <- rast(naip_extent, res = res(rast(array_tifs[1])), crs = crs(naip_pa))

# impose template raster: https://stackoverflow.com/a/72420327/12500603

out.mosaic <- paste0("/storage/home/kbl5733/gstorage/data/deepflora/maps/mosaic/",basename(array_dir),".tif")

# imposing on sprc (maybe uses more memory)
impose(sprc(array_tifs), temp, filename = out.mosaic, overwrite = TRUE)
