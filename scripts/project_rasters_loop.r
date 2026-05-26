start.t <- Sys.time()
library(terra)

args <- commandArgs(trailingOnly = TRUE)
state <- args[1]

# get mosaic tifs
arraytifs <- list.files(
  paste0("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/", state, "_250_2017/256m_2017_-1_db_", state, "_2017_8"),
           recursive = TRUE, full.names = TRUE, pattern = "*raw.tif")

temp.ras <- readRDS(paste0("data/template_", state, ".rds"))

outdir <- file.path("/storage/home/kbl5733/gstorage/data/deepflora/maps",
                    paste0(state,"_2017_albers"))

if(!exists(outdir)){
  dir.create(outdir)
}

for(i in seq_along(arraytifs)){
  arraytif.i <- rast(arraytifs[i])

  cat("Projecting raster", i, "for", state, "\n")

  projtif <- project(arraytif.i, temp.ras)

  fname <- paste0("albers_", basename(arraytifs[i]))

  writeRaster(projtif, file.path(outdir, fname))

  i.t <- as.numeric(Sys.time() - start.t, unit = "mins")

  cat("Tile", i, "written to:", file.path(outdir, fname), "\n",
      "It took", round(i.t, digits = 1), "minutes\n")

}

