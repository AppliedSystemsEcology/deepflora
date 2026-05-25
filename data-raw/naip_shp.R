library(terra)
source("R/azure_from_index.R")

# PA
download_from_index("https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_shpfl_2017/index.html",
                    "data-raw/naipshp/")
# NY
download_from_index("https://naipeuwest.blob.core.windows.net/naip/v002/ny/2017/ny_shpfl_2017/index.html",
                    "data-raw/naipshp/")

# read in data

pa_naip <- vect("data-raw/naipshp/pa_shpfl_2017/naip_pa_2017_100_m4b.shp")
ny_naip <- vect("data-raw/naipshp/ny_shpfl_2017/naip_3_17_2_9_ny.shp")

# project to Albers Conical Equal Area, NAD 83
if(!dir.exists("data/extents/")){dir.create("data/extents")}

pa_naip_albers <- terra::project(pa_naip, "epsg:5070")
ny_naip_albers <- terra::project(ny_naip, "epsg:5070")

writeVector(pa_naip_albers, filename="data/extents/naip_pa_albers.geojson", overwrite=TRUE)
writeVector(ny_naip_albers, filename="data/extents/naip_ny_albers.geojson", overwrite=TRUE)


# ON HPC: MAKE TEMPLATE RASTER
# 250 M TEMPLATE
library(terra)

pa.v <- vect("data/extents/naip_pa_albers.geojson")
ny.v <- vect("data/extents/naip_ny_albers.geojson")
