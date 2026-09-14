library(terra)
library(sf)
library(tidyverse)

nydir <- "/storage/home/kbl5733/gstorage/data/deepflora/maps/tiles"
pts <- st_read("scripts/aaron/iverson_pts_naipjoin.geojson")

tiles <- unique(pts$FileName)

outlist <- list()

for(i in seq_along(tiles)){
  tile.i <- rast(file.path(nydir,paste0("ny_30m_",tiles[i],"_raw.tif")))
  pts.i <- pts |> dplyr::filter(FileName == tiles[i])

  extract.i <- terra::extract(tile.i, pts.i, ID = FALSE)
  rownames(extract.i) <- pts.i$site

  outlist[[tiles[i]]] <- extract.i |> tibble::rownames_to_column(var = "site")
}

outdf <- dplyr::bind_rows(outlist, .id = "tile")

write.csv(outdf, "data-raw/aaron_30m_extract.csv", row.names = FALSE)
