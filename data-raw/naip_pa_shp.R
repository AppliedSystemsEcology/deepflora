source("R/azure_from_index.R")

naipshp <- azure_from_index("https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_shpfl_2017/index.html")

for(i in seq_along(naipshp)){
  download.file(naipshp[i], file.path("data-raw","naipshp",basename(naipshp[i])))
}

# read in data
library(terra)

pa_naip <- vect("data-raw/naipshp/naip_pa_2017_100_m4b.shp")

# project to Albers Conical Equal Area, NAD 83
if(!dir.exists("data/extents/")){dir.create("data/extents")}

pa_naip_albers <- terra::project(pa_naip, "epsg:5070")

writeVector(pa_naip_albers, filename="data/extents/naip_pa_albers.geojson", overwrite=TRUE)
