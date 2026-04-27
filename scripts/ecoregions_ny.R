library(terra)

l3 <- vect("/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/raw/us_eco_l3_state_boundaries.shp")

l3_ny <- terra::subset(l3, l3$STATE_NAME == "New York")

bioclim_crs <- crs(rast("/storage/group/hlc30/default/data/deepflora/RASTERS/bioclim_current/wc_30s_current/wc2.1_30s_bio_10.tif"))

l3_ny_wgs84 <- terra::project(l3_ny, bioclim_crs)

if(!dir.exists("/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/ny")){
  dir.create("/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/ny")
}

writeVector(l3_ny_wgs84, "/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/ny/ny_eco_l3.shp", overwrite = TRUE)
