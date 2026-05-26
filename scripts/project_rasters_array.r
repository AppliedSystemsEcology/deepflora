library(terra)

arraynum <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
state <- Sys.getenv("STATE")

# get mosaic tifs
arraytifs <- list.files(
  paste0("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/", state, "_250_2017/256m_2017_-1_db_", state, "_2017_8"),
           recursive = TRUE, full.names = TRUE, pattern = "*raw.tif")

arraytif <- rast(arraytifs[arraynum])

temp.ras <- readRDS(paste0("data/template_", state, ".rds"))

cat("Projecting raster", arraynum, "for", state, "\n")

projtif <- project(arraytif, temp.ras)

outdir <- file.path("/storage/home/kbl5733/gstorage/data/deepflora/maps",
                    paste0(state,"_2017_albers"))

if(!exists(outdir)){
  dir.create(outdir)
}

fname <- paste0("albers_", basename(arraytifs[arraynum]))

writeRaster(projtif, file.path(outdir, fname))

cat("Tile", arraynum, "written to:", file.path(outdir, fname), "\n")
