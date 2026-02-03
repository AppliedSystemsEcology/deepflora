# deepflora
Adapting deepbiosphere for mapping pollinator floral resources

For linux install on Roar Collab.

### Make the `conda` env with python packages included

As many as possible with the `conda create` command. `inplace_abn` cannot be installed like this.

```         

# Start gpu

salloc -A hlc30_p100_default -p sla-prio --gres=gpu:p100:1

# check CUDA version
nvidia-smi   # for p100 CUDA version 13.0 (this is highest but for deepbiosphere need something like 11.5.0)

# make conda env NEED python >3.7  but <3.10

conda create -n deepflora python=3.9 pip=22.3 setuptools=65 -y

# Note: how to remove env (after deactivating)
conda remove -n <envname> --all
```

### Install pytorch

```         

conda activate deepflora
  
pip install torch==1.10.2+cu113 torchvision==0.11.3+cu113 torchaudio==0.10.2 --extra-index-url https://download.pytorch.org/whl/cu113 --no-cache-dir

pip install "numpy<2.0"

conda install \
  r-base=4.3 \
  rpy2 \
  gcc_linux-64 \
  gxx_linux-64 \
  libstdcxx-ng \
  -c conda-forge -y

# load cuda module (different from torch cuda, they do not need to be the same minor version per chatgpt)

module avail cuda
module load cuda/11.5.0  # load CUDA version compatible with inplace-abn?
```

### test if pytorch is installed IN PYTHON

```python

import torch
torch.cuda.is_available()

```

### Install inplace_abn

`inplace_abn` requires pytorch to be installed but a recent change causes installation to be in an isolated environment. [Turn this off.](https://stackoverflow.com/questions/79285272/modulenotfounderror-no-module-named-torch-but-torch-is-installed)

```         

# install inplace_abn
pip install inplace-abn
```

### Install *deepbiosphere*

```         

pip install -e git+https://github.com/moiexpositoalonsolab/Deepbiosphere.git#egg=deepbiosphere
```

### Downgrade `setuptools`

PyTorch 1.10.x expects `distutils.version.LooseVersion` to exist. But the `deepflora` environment has a newer Python packaging stack where `distutils` is partially removed / stubbed and `setuptools` has taken over.

Downgrading `setuptools` is a standard fix for torch ≤ 1.12 (according to chatgpt).

```         

pip install "setuptools<68"

conda install python-distutils -c conda-forge   # may not be necessary; it didn't change anything
```

In `src/deepbiosphere/Utils.py`, replace the `paths` definition with

```         

paths = SimpleNamespace(
  OCCS = '/storage/group/hlc30/default/data/deepflora/OCCS/',
  SHPFILES = '/storage/group/hlc30/default/data/deepflora/SHPFILES/',
  MODELS = '/storage/group/hlc30/default/data/deepflora/MODELS/',
  IMAGES = '/storage/group/hlc30/default/data/deepflora/IMAGES/',
  RASTERS = '/storage/group/hlc30/default/data/deepflora/RASTERS/',
  BASELINES = '/storage/group/hlc30/default/data/deepflora/BASELINES/',
  RESULTS = '/storage/group/hlc30/default/data/deepflora/RESULTS/',
  MISC = '/storage/group/hlc30/default/data/deepflora/MISC/',
  DOCS = '/storage/group/hlc30/default/data/deepflora/DOCS/',
  SCRATCH = '/storage/group/hlc30/default/data/deepflora/SCRATCH/',
  RUNS = '/storage/group/hlc30/default/data/deepflora/RUNS/',
  MEANS='/storage/group/hlc30/default/data/deepflora/MEANS/',
  BLOB_ROOT = 'https://naipblobs.blob.core.windows.net/')
```

### make a change to `__init__.py`

Make a backup first: `cp __init__.py __init__.py.bak`

Replace entirety of `src/deepbiosphere/__init__.py` with:

```python

"""
DeepBiosphere package.

Heavy submodules (torch, NAIP processing, training code)
are intentionally not imported at package import time.
Import them explicitly when needed.
"""


```

## Download GBIF data

### Set up GBIF

Set up a `.netrc` file, instructions in [the repository](https://github.com/moiexpositoalonsolab/deepbiosphere?tab=readme-ov-file#setting-up-access-on-gbif).

#### debug gadm input

In `Download_GBIF_Data.py`, the administrative area argument is handled as if it might be a list of areas, but when you pass a single string, it never gets wrapped properly.

In `Download_GBIF_Data.py`, add the following after `args, _ = args.parse_known_args()`

```python

if isinstance(args.area, str):
    args.area = [args.area]

```

### Run `Download_GBIF_Data.py

```

# make the target directories
mkdir /storage/group/hlc30/default/data/deepflora/{OCCS,SHPFILES,MODELS,IMAGES,RASTERS,BASELINES,RESULTS,MISC,DOCS,SCRATCH,RUNS}

python src/deepbiosphere/Download_GBIF_Data.py --gbif_user [your_username] --gbif_email [your_gbif_email] --organism plant --start_date 2015 --end_date 2022

python src/deepbiosphere/src/deepbiosphere/Download_GBIF_Data.py --gbif_user neivkli --gbif_email likevin@umich.edu --organism plant --start_date 2015 --end_date 2025 --area "USA.39_1"

```

## [Build training and testing dataset](https://github.com/moiexpositoalonsolab/Deepbiosphere?tab=readme-ov-file#building-the-training-and-testing-dataset-for-deepbiosphere)

### Debug

#### A circular import error

> `Build_Data.py`
> 
> ```python
> import deepbiosphere.NAIP_Utils as naip
> ```
> 
> `NAIP_Utils.py`
> 
> ```python
> import deepbiosphere.Dataset as dataset
> ```
> 
> `Dataset.py`
> 
> ```python
> import deepbiosphere.Build_Data as build
> ```
> 
> This goes back to `Build_Data.py` while it’s still loading.

This is a circular-import error. `naip.CRS` doesn’t exist yet because inside `NAIP_Utils.py`, the CRS object is defined after imports:

```python
class CRS:
    BIOCLIM_CRS = ...
```

But when Python reaches this line in Build_Data.py:

`crs=naip.CRS.BIOCLIM_CRS`

NAIP_Utils.py is only partially executed; Python hasn’t reached the CRS class definition yet.

So `naip.CRS` doesn’t exist yet, and Python throws:

`AttributeError: partially initialized module`

##### Fix: move the CRS default into the function body

In `Build_Data.py`, find **`get_bioclim_rasters`**:

```python

def get_bioclim_rasters(
    base_dir=paths.RASTERS,
    train_dir=paths.RASTERS,
    ras_name='wc_30s_current',
    timeframe='current',
    crs=naip.CRS.BIOCLIM_CRS,
    state='ca'
):

```

At the top of this function, add: 

```python
    if crs is None:
        crs = naip.CRS.BIOCLIM_CRS
```

#### Patch `Run.py`

Open `src/deepbiosphere/src/deepbiosphere/Run.py`

Replace `from torch.utils.tensorboard import SummaryWriter` with 

```python

def _get_summary_writer():
    from torch.utils.tensorboard import SummaryWriter
    return SummaryWriter

```

Wherever `SummaryWriter` is used, change `SummaryWriter(...)` to  `_get_summary_writer()(...)`.

#### Pre-load gadm data

The code assumes the [gadm3.6 geographic boundaries dataset](https://gadm.org/download_country36.html) is already loaded into the `SHP/` data folder. This needs to be done manually.

```
cd /storage/group/hlc30/default/data/deepflora/SHPFILES/
wget https://geodata.ucdavis.edu/gadm/gadm3.6/shp/gadm36_USA_shp.zip
unzip gadm36_USA_shp.zip -d gadm36_USA

```

#### Pre-load bioclim data

The code assumes the [bioclim dataset](https://www.worldclim.org/data/worldclim21.html) is already loaded. This has to be added manually (30s)

```
cd /storage/group/hlc30/default/data/deepflora/RASTERS/
wget https://geodata.ucdavis.edu/climate/worldclim/2_1/base/wc2.1_30s_bio.zip
unzip wc2.1_30s_bio.zip -d wc_30s_current

```

#### Pre-load EPA l3 ecoregion data and clip PA

Code assumes [EPA ecoregion dataset]() (level 3) exists in the SHAPEFILES folder. Add this manually.

```
mkdir -p /storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/raw
cd /storage/group/hlc30/default/data/deepflora/SHPFILES/ecoregions/raw

wget https://dmap-prod-oms-edc.s3.us-east-1.amazonaws.com/ORD/Ecoregions/us/us_eco_l3_state_boundaries.zip
unzip us_eco_l3_state_boundaries.zip

```

Files are available for entire US, so clip to PA. This is run in R so use a separate `env` set up for R geoprocessing since I couldn't get the install to work on `deepflora`

```r

R -f /storage/home/kbl5733/work/github/deepflora/scripts/ecoregions_pa.R

```

#### Pre-load NAIP imagery

NAIP imagery is not downloaded in the repo code. It has to be done independently.

Download NAIP footprints using shell script `azure_from_index.sh`

```    
chmod +x /storage/home/kbl5733/work/github/deepflora/scripts/azure_from_index.sh # allow execution

/storage/home/kbl5733/work/github/deepflora/scripts/azure_from_index.sh \
-b https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_shpfl_2017 \
-o /storage/group/hlc30/default/data/deepflora/SHPFILES/naip_tiffs/pa_shpfl_2017

```

Download NAIP imagery

#### State lat-lon max and min

Looking into the `Build_Dataset.py` code, it looks like the function `make_spatial_split` makes some assumptions about lat-long max and mins based on California. It doesn't look like these can be changed without changing the function defaults because the `make_dataset` that calls it and actually takes in the arguments from the user doesn't pass these options on.

Change the code in `build_dataset` to draw the max/min from the state shapefile. This is added immediately before the call to `make_spatial_split` in the definition of `make_dataset`. Then add argument definitions for `latmin`, `lonmin`, `latmax`, and `lonmax`.

```python
    minx, miny, maxx, maxy = shps.total_bounds
    daset = make_spatial_split(daset, latname, latmin = miny, latmax = maxy, lonmin = minx, lonmax = maxx)
```

Also, change `make_spatial_split` function so that it ensures the calculated `strtlat` and `endlat` values are integers.

Change the lines defining `strtlat` and `endlat` to:

```python
strtlat = int(max(math.floor(latmin), math.floor(daset[latCol].min())))
endlat = int(min(math.floor(latmax), math.ceil(daset[latCol].max())))
```

#### Change `compute_means` function in `Build_Dataset.py` to be more robust

The function `compute_means` assumes that `dataset_means.json` already exists. I changed it so that it will create a json file in the `MEANS/` folder it it's not there.

Replace top of function:

```python
f = f"{paths.MEANS}dataset_means.json"

if os.path.exists(f):
    with open(f, 'r') as fp:
        daset_means = json.load(fp)
else:
    daset_means = {}

key = f"{state}_naip_{year}"
if key not in daset_means:
    daset_means[key] = {}
```

at the end of function, replace the part defining `daset_means` contents with:

```python
daset_means[key]['means'] = mean
daset_means[key]['stds'] = std
```


### Run `Build_data.py`:

In home directory:

```

# run with 26 cores using sbatch script at /storage/home/kbl5733/work/github/deepflora/scripts/build_data_parallel.sh

sbatch work/github/deepflora/scripts/build_data_parallel.sh

# this is equivalent of:
python src/deepbiosphere/src/deepbiosphere/Build_Data.py --dset_path /storage/group/hlc30/default/data/deepflora/OCCS/plant_2015_2025_USA_39_1_acq2026_1_27.csv --daset_id plants_pa --sep '\t' --year 2017 --state pa --threshold 500 --idCol gbifID --parallel 26

```
