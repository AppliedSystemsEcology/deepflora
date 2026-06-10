library(geodata)

usa <- gadm("USA", level = 1, "data/spatial")
saveRDS(usa, "data/spatial/usa.rds")
