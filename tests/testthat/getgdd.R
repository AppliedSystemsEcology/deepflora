# load prismgrid
prismgrid <- terra::rast("data-raw/gdd/prismgrid.grd")

plants_prismid <- terra::extract(prismgrid, terra::vect(top100_sf))

plants_gdd <- plant_df  %>%
  mutate(
    eventDate = as.Date(eventDate),
    week = factor(format(eventDate, "%V"), levels = sprintf("%02d", 1:52))) %>%
  mutate(gdd = get_gdd(eventDate, lon = decimalLongitude, lat = decimalLatitude))%>%
  mutate(prismid = plants_prismid$id) %>%
  mutate(gdd = getgddvec(prismid = prismid, year=year, week=week)) %>%
  mutate(gdd2 = getgdd_prismid(prismid = prismid, year=year, week=week)) %>%
  mutate(gdd3 = get_gdd(eventDate, lon = decimalLongitude, lat = decimalLatitude))
