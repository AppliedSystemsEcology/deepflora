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

# get naip file example
naipfiles_pa <- list.files("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/pa_250_2017/256m_2017_-1_db_pa_2017_8",
                      recursive = TRUE, full.names = TRUE, pattern = "*raw.tif")
pa.r <- rast(naipfiles_pa[1])

naipfiles_ny <- list.files("/storage/home/kbl5733/gstorage/data/deepflora/RASTERS/ny_250_2017/256m_2017_-1_db_ny_2017_8",
                           recursive = TRUE, full.names = TRUE, pattern = "*raw.tif")
ny.r <- rast(naipfiles_ny[1])

all.equal(res(ny.r), res(pa.r))

# make the template rasters for PA and NY
res <- res(pa.r)[1]
e.pa <- ext(pa.v)
e.ny <- ext(ny.v)

origin_x.pa <- floor(e.pa$xmin / res) * res
origin_y.pa <- ceiling(e.pa$ymax / res) * res

origin_x.ny <- floor(e.ny$xmin / res) * res
origin_y.ny <- ceiling(e.ny$ymax / res) * res

temp_pa <- rast(
  xmin = origin_x.pa,
  xmax = ceiling(e.pa$xmax / res) * res,
  ymin = floor(e.pa$ymin / res) * res,
  ymax = origin_y.pa,
  resolution = res,
  crs = "epsg:5070"
)

temp_ny <- rast(
  xmin = origin_x.ny,
  xmax = ceiling(e.ny$xmax / res) * res,
  ymin = floor(e.ny$ymin / res) * res,
  ymax = origin_y.ny,
  resolution = res,
  crs = "epsg:5070"
)

saveRDS(temp_pa, "data/template_pa.rds")
saveRDS(temp_ny, "data/template_ny.rds")
