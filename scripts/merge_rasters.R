library(terra)
# final merge

args <- commandArgs(trailingOnly = TRUE)
in.dir <- args[1]    # input directory
species <- args[2]   # species band
out.dir <- args[3]   # output directory

tiles <- list.files(in.dir,
           pattern = "*.tif", full.names = TRUE)

cat("Mosaicing", length(tiles), "tiles\n")

# The Filter(Negate(is.null), ...) removes any NULL entries returned by failed tiles before passing to sprc.
tiles_sprc <- terra::sprc(Filter(Negate(is.null), lapply(tiles, function(x) {
  tryCatch({
    r <- rast(x)
    if (!species %in% names(r)) stop(paste("Species", species, "not found in", x))
    r[[species]]
  }, error = function(e) {
    cat("Skipping:", basename(x), "-", conditionMessage(e), "\n")
    NULL
  })
})))

out.fname <- file.path(out.dir, paste0(basename(in.dir),"_",sub(" ", "_", species),".tif"))

cat("Writing out", species, "to", out.fname, "\n")

terra::mosaic(tiles_sprc,
              filename = out.fname,
              overwrite = TRUE,
              gdal = c("COMPRESS=LZW", "BIGTIFF=YES")
              )
