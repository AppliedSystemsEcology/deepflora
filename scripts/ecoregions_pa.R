library(terra)

l3 <- vect("/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/raw/us_eco_l3_state_boundaries.shp")

l3_pa <- terra::subset(l3, l3$STATE_NAME == "Pennsylvania")

bioclim_crs <- crs(rast("/storage/group/hlc30/default/data/deepflora/RASTERS/bioclim_current/wc_30s_current/wc2.1_30s_bio_10.tif"))

l3_pa_wgs84 <- terra::project(l3_pa, bioclim_crs)

if(!dir.exists("/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/pa")){
  dir.create("/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/pa")
}

writeVector(l3_pa_wgs84, "/storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/pa/pa_eco_l3.shp", overwrite = TRUE)
