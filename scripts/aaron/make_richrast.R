library(terra)
library(sf)
library(tidyverse)

nydir <- "/storage/home/kbl5733/gstorage/data/deepflora/maps/tiles"
pts <- st_read("scripts/aaron/iverson_pts_naipjoin.geojson")

tiles <- unique(pts$FileName)

outlist <- list()

for(i in seq_along(tiles)){

  tile.i <- rast(file.path(nydir,paste0("ny_30m_",tiles[i],"_raw.tif")))

  # map richness

  pres.i <- tile.i > 0.5
  rich.i <- sum(pres.i)

  writeRaster(rich.i, file.path("data/aaron",paste0("rich_",tiles[i])))

}
