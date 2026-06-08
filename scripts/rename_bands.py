import rasterio
import glob
import sys

in_dir  = sys.argv[1]
mosaic_path = sys.argv[2]

tiles = glob.glob(os.path.join(in_dir, "*.tif"))

source_tile = tiles[0]  # any tile with band names

with rasterio.open(source_tile) as src:
    descriptions = src.descriptions

with rasterio.open(mosaic_path, 'r+') as dst:
    for i, name in enumerate(descriptions, 1):
        dst.update_tags(i, name=name)
    print(f"Updated {len(descriptions)} band names")
