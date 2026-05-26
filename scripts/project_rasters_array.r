start.t <- Sys.time()
library(terra)

arraynum <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))
args <- commandArgs(trailingOnly = TRUE)
state <- args[1]

# get folder for this array job
arraydir <- list.dirs(
  paste0("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/", state, "_250_2017/256m_2017_-1_db_", state, "_2017_8"),
  full.names = TRUE
)

thisarray <- arraydir[arraynum]

# get mosaic tifs

arraytifs <- list.files(thisarray, recursive = TRUE, full.names = TRUE, pattern = "*raw.tif")

temp.ras <- readRDS(paste0("data/template_", state, ".rds"))

outdir <- file.path("/storage/home/kbl5733/gstorage/data/deepflora/maps",
                    paste0(state,"_2017_albers"))

if(!exists(outdir)){
  dir.create(outdir)
}

for(i in seq_along(arraytifs)){
  fname <- paste0("albers_", basename(arraytifs[i]))
  fname.outpath <- file.path(outdir, fname)

  if(file.exists(fname.outpath)){
    cat("File", fname, "already exists at", outdir, "\n")
    next
  }

  arraytif.i <- rast(arraytifs[i])

  cat("Projecting raster", i, "of", length(arraytifs), "for", basename(thisarray), "\n")

  projtif <- project(arraytif.i, temp.ras)

  writeRaster(projtif, fname.outpath)

  i.t <- as.numeric(Sys.time() - start.t, unit = "mins")

  cat("Tile", i, "written to:", file.path(outdir, fname), "\n",
      "It took", round(i.t, digits = 1), "minutes\n")

}

