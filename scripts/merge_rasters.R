library(terra)
# final merge

args <- commandArgs(trailingOnly = TRUE)
in.dir <- args[1]    # input directory
species <- args[2]   # species band
out.dir <- args[3]   # output directory

tiles <- list.files(in.dir,
           pattern = "*.tif", full.names = TRUE)

cat("Mosaicing", length(tiles), "tiles\n")

tiles_sprc <- terra::sprc(lapply(tiles, function(x) {
  r <- rast(x)
  if (!species %in% names(r)) stop(paste("Species", species, "not found in", x))
  r[[species]]
}))

out.fname <- file.path(out.dir, paste0(basename(in.dir),"_",sub(" ", "_", species),".tif"))

cat("Writing out", species, "to", out.fname, "\n")

terra::mosaic(tiles_sprc,
              filename = out.fname,
              overwrite = TRUE,
              gdal = c("COMPRESS=LZW", "BIGTIFF=YES")
              )
