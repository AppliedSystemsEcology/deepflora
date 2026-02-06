import deepbiosphere.Build_Data as bd
import deepbiosphere.NAIP_Utils  as naip
import geopandas as gpd

shps = naip.get_state_outline("pa")

# shps bounds
minx, miny, maxx, maxy = shps.total_bounds

polys = bd.generate_split_polygons(lonmin = minx, lonmax = maxx, latmin = miny, latmax = maxy, axis = "lon")

rows = []
for band, parts in polys.items():
    for geom in parts['train']:
        rows.append({'band': band, 'type': 'train', 'geometry': geom})
    rows.append({'band': band, 'type': 'test', 'geometry': parts['test']})
    for geom in parts['exclusion']:
        rows.append({'band': band, 'type': 'exclusion', 'geometry': geom})

gdf = gpd.GeoDataFrame(rows, crs="EPSG:4326")

gdf.to_file("spatial_cv_bands.gpkg", layer="bands", driver="GPKG")
