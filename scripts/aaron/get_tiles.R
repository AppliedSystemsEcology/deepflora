library(sf)

nynaip <- st_read("data/extents/naip_ny_albers.geojson")
pts <- st_read("scripts/aaron/iverson_pts.geojson") |> st_transform(crs = st_crs(nynaip))

# find tiles that contain Aaron's points

tiles_pts <- nynaip[pts,]

tilenames <- strsplit(tiles_pts$FileName, "_") |>
  lapply(\(x)  paste0(paste(x[1:(length(x)-1)], collapse="_"), ".tif"))

writeLines(unlist(tilenames), "scripts/aaron/filenames.txt")

# match Aaron's points to tiles

pts_join_tiles <- sf::st_join(pts, nynaip) |>
  dplyr::mutate(FileName = paste0(stringr::str_remove(FileName, "_[^_]+$"),".tif"))

sf::st_write(pts_join_tiles, "scripts/aaron/iverson_pts_naipjoin.geojson")
