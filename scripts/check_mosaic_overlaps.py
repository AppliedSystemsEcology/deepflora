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

overlapping_pairs = [(tiles[i], tiles[j]) 
                     for i, a in enumerate(boxes) 
                     for j, b in enumerate(boxes[i+1:], i+1) 
                     if a.intersects(b)]

# Look at overlap area as % of tile area for first few pairs
for t1, t2 in overlapping_pairs[:5]:
    i, j = tiles.index(t1), tiles.index(t2)
    overlap_area = boxes[i].intersection(boxes[j]).area
    tile_area = boxes[i].area
    print(f"{os.path.basename(t1)} x {os.path.basename(t2)}: {100*overlap_area/tile_area:.1f}% overlap")
    
for s in srcs: s.close()
