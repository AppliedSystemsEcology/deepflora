import sys
import os
import glob
import numpy as np
import rasterio
from rasterio.merge import merge
from rasterio.windows import from_bounds as win_from_bounds

in_dir  = sys.argv[1]
out_dir = sys.argv[2]

tiles = glob.glob(os.path.join(in_dir, "*.tif"))
print(f"Mosaicking {len(tiles)} tiles")

out_fname = os.path.join(out_dir, os.path.basename(in_dir) + "_mosaic.tif")

# Open all tiles
srcs = [rasterio.open(t) for t in tiles]

# Get output extent/transform
tmp, out_transform = merge(srcs, method='first', indexes=[1])
out_shape = tmp.shape[1:]

profile = srcs[0].profile.copy()
profile.update(width=out_shape[1], height=out_shape[0],
               transform=out_transform, count=srcs[0].count,
               compress='lzw', bigtiff='YES')

with rasterio.open(out_fname, 'w', **profile) as dst:
    for band_idx in range(1, srcs[0].count + 1):
        sum_arr = np.zeros(out_shape, dtype=np.float64)
        count_arr = np.zeros(out_shape, dtype=np.uint8)

        for src in srcs:
            win = win_from_bounds(*src.bounds, out_transform, out_shape[0], out_shape[1])
            data = src.read(band_idx, window=win, out_shape=out_shape,
                            resampling=rasterio.enums.Resampling.nearest)
            valid = np.isfinite(data)
            sum_arr[valid] += data[valid]
            count_arr[valid] += 1

        mean_arr = np.where(count_arr > 0, sum_arr / count_arr, np.nan)
        dst.write(mean_arr.astype(np.float32), band_idx)

        if band_idx % 100 == 0:
            print(f"Band {band_idx}/{srcs[0].count} done")

for s in srcs: s.close()
print(f"Written to {out_fname}")
