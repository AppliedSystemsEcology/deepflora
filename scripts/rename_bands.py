import rasterio
import glob
import sys
import os

in_dir  = sys.argv[1]
mosaic_path = sys.argv[2]

tiles = glob.glob(os.path.join(in_dir, "*.tif"))

source_tile = tiles[0]  # any tile with band names

with rasterio.open(source_tile) as src:
    descriptions = src.descriptions  # reads native GeoTIFF band descriptions

with rasterio.open(mosaic_path, 'r+') as dst:
    dst.descriptions = descriptions
    print(f"Updated {len(descriptions)} band descriptions")
