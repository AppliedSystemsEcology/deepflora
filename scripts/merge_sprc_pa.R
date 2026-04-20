library(terra)
terraOptions(memfrac = 0.6, tempdir = "/scratch/kbl5733/tmp", threads = 8)

# get the NAIP full PA extent vector
naip_pa <-vect("data/extents/naip_pa_albers.geojson")

# get the extent
naip_extent <- ext(naip_pa) + 1

# load the merged naip images (merged into larger tiles)
pa_tiles <- list.files("/storage/home/kbl5733/gstorage/data/deepflora/maps/mosaic/",
                         full.names = TRUE)

pa_ras <- lapply(pa_tiles, rast)

# make a template raster from extent for output
temp <- rast(naip_extent, res = res(pa_ras[[1]]), crs = crs(naip_pa))

# figure out which UTM projection is for which tile
pa_utm <- sapply(pa_ras, terra::crs)

# make sprc for each utm and impose the template raster
pa_sprc_1 <- impose(sprc(pa_tiles[pa_utm == unique(pa_utm)[1]]), temp)
pa_sprc_2 <- impose(sprc(pa_tiles[pa_utm == unique(pa_utm)[2]]), temp)

pa_merge <- merge(pa_sprc_1, pa_sprc_2,
                  filename = "/storage/home/kbl5733/gstorage/data/deepflora/maps/state/pa.tif")


