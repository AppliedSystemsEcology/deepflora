library(terra)

mdir <- "/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_merge"

mtifs <- list.files(mdir)

testdir <- file.path(dirname(mdir), "ny_mosaic_test")
dir.create(testdir)

for (i in seq_along(mtifs)){
  tif.i <- rast(file.path(mdir,mtifs[i]))

  writeRaster(tif.i[[1]], file.path(testdir,mtifs[i]), overwrite = TRUE)
}
