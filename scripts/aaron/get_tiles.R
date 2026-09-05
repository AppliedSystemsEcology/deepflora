library(sf)

nynaip <- st_read("data/extents/naip_ny_albers.geojson")
pts <- st_read("scripts/aaron/iverson_pts.geojson") |> st_transform(crs = st_crs(nynaip))

tiles_pts <- nynaip[pts,]

tilenames <- strsplit(tiles_pts$FileName, "_") |>
  lapply(\(x)  paste0(paste(x[1:(length(x)-1)], collapse="_"), ".tif"))

writeLines(unlist(tilenames), "scripts/aaron/filenames.txt")
