library(terra)
# final merge

args <- commandArgs(trailingOnly = TRUE)
in.dir <- args[1] # directory containing tile group dirs
out.dir <- args[2]   # output directory
array.n <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

array.dir <- read.csv("scripts/pa_dirs.csv")[array.n,"dir"]

tiles <- list.files(in.dir, pattern = paste0(array.dir), full.names = TRUE)

cat("Mosaicing", length(tiles), "tiles in group", array.dir, "\n")

# The Filter(Negate(is.null), ...) removes any NULL entries returned by failed tiles before passing to sprc.
tiles_sprc <- terra::sprc(Filter(Negate(is.null), lapply(tiles, function(x) {
  tryCatch({
    rast(x)
  }, error = function(e) {
    cat("Skipping:", basename(x), "-", conditionMessage(e), "\n")
    NULL
  })
})))

out.fname <- file.path(out.dir, paste0(basename(in.dir), "_", array.dir,".tif"))

cat("Writing out to", out.fname, "\n")

terra::mosaic(tiles_sprc,
              filename = out.fname,
              overwrite = TRUE,
              gdal = c("COMPRESS=LZW", "BIGTIFF=YES")
              )
