library(terra)
library(sf)

load("data-raw/gdd/week2016.RDS")
prismgrid <- terra::rast("data/prismgrid_wgs84.tif")
values(prismgrid) <- week2016[,1]

NEext <- ext(prismgrid) |> as.polygons(crs = crs(prismgrid)) |> sf::st_as_sf()
NEstates <- ifel(!is.na(prismgrid),1,NA) |> as.polygons() |> sf::st_as_sf()

saveRDS(NEext, "data/gddNEext.rds")
saveRDS(NEstates, "data/gddNEstates.rds")
