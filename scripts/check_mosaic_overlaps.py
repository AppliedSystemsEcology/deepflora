# Quick sanity check for overlaps before running
import sys
import glob
import os
from shapely.geometry import box
import rasterio

in_dir  = sys.argv[1]
tiles = glob.glob(os.path.join(in_dir, "*.tif"))

srcs = [rasterio.open(t) for t in tiles]
boxes = [box(*src.bounds) for src in srcs]
overlaps = sum(1 for i, a in enumerate(boxes) for b in boxes[i+1:] if a.intersects(b))
print(f"{overlaps} overlapping tile pairs")
for s in srcs: s.close()
