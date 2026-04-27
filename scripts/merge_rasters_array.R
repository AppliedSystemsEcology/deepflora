library(terra)

arraynum <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
naipdirs <- list.dirs("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/pa_250/256m_2017_-1_initial_7",
                      recursive = FALSE, full.names = TRUE)

array_dir <- naipdirs[arraynum]

cat("Tile", basename(array_dir), "is being handled by job", Sys.getenv("SLURM_ARRAY_TASK_ID"), "\n")

# get mosaic tifs
array_tifs <- list.files(array_dir, pattern = "*raw.tif", full.names = TRUE)

# make a template raster from extent for output
naip_pa <-vect("/storage/home/kbl5733/work/github/deepflora/data/extents/naip_pa_albers.geojson") # get the NAIP full PA extent vector
naip_extent <- ext(naip_pa) + 1
temp <- rast(naip_extent, res = res(rast(array_tifs[1])), crs = crs(naip_pa))

# mosaic and then project
out.mosaic <- paste0("/storage/home/kbl5733/gstorage/data/deepflora/maps/mosaic/",basename(array_dir),".tif")

tmp_mosaic <- file.path("/scratch/kbl5733/tmp", paste0(basename(array_dir), "_tmp.tif"))

cat("Mosaicking to", tmp_mosaic, "\n")
mosaic(sprc(array_tifs), fun = "mean", filename = tmp_mosaic, overwrite = TRUE)

cat("Projecting...")
project(rast(tmp_mosaic), temp, method = "bilinear", filename = out.mosaic, overwrite = TRUE)

cat("Mosaicked output to", out.mosaic, "\n")
