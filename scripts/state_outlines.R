library(sf)
library(tidyverse)

# on hpc
us <- st_read("/storage/home/kbl5733/gstorage/data/deepflora/SHPFILES/gadm36_USA/gadm36_USA_1.shp")

ny <- us |> filter(NAME_1 == "New York")

st_write(ny, "/storage/home/kbl5733/gstorage/data/deepflora/SHPFILES/states/ny.shp")

