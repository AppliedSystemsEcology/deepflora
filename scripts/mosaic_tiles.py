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
with rasterio.open(tiles[0]) as src:
    out_shape = (src.height, src.width)
    out_transform = src.transform

profile = srcs[0].profile.copy()
profile.update(
    width=out_shape[1], height=out_shape[0],
    transform=out_transform, count=srcs[0].count,
    compress='lzw', bigtiff='YES',
    tiled=True, blockxsize=256, blockysize=256,
    interleave='band', num_threads='ALL_CPUS',
    sparse_ok='YES', nodata=np.nan
)

with rasterio.open(out_fname, 'w', **profile) as dst:
    band_descriptions = srcs[0].descriptions

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
            print(f"{os.path.basename(in_dir)} band {band_idx}/{srcs[0].count} done")

    # Set descriptions once after all bands are written
    dst.descriptions = band_descriptions

for s in srcs: s.close()
print(f"Written to {out_fname}")
