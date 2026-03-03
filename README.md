# deepflora
Adapting deepbiosphere for mapping pollinator floral resources

## To set up the conda env:

Make anaconda is loaded on the hpc. Then create a conda env using `scripts/environment.yml`:

```
conda env create -f scripts/environment.yml
```

Note that the script needs `requirements.txt` to run. The last item in this file needs to point to a local version of the custom deepbiosphere repository at https://github.com/AppliedSystemsEcology/deepbiosphere-pa. This can be created by cloning the repository and changing the filepath to the cloned file location.

```
--extra-index-url https://download.pytorch.org/whl/cu113
torch==1.10.2+cu113
torchvision==0.11.3+cu113
torchaudio==0.10.2
numpy<2.0
tensorboard<2.11
inplace-abn
-e /storage/home/kbl5733/src/deepbiosphere   # change to local deepbiosphere repo clone
```

## Set up directories for deepbiosphere

Directory paths need to be set before running deepbiosphere. In `src/deepbiosphere/Utils.py`, replace the `paths` definition with

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

The shapefile is for the entire US, so clip to PA. This is run in R so use a separate `env` set up for R geoprocessing since I couldn't install `terra` on `deepflora`

```r

R -f /storage/home/kbl5733/work/github/deepflora/scripts/ecoregions_pa.R

```

#### Pre-load NAIP imagery

NAIP imagery is not downloaded in the repo code. It has to be done independently.

There are scripts to extract the data links from the index files within the server hosting NAIP imagery. There's a `sh` version and an `R` version. The `sh` version actually downloads the files in the link while the `R` version returns the links as strings in the index.html. The `R` version is useful for looping through directories on the server, where the provided index.html is listing directories rather than data.

##### Download NAIP footprints using shell script `azure_from_index.sh`

```    
chmod +x /storage/home/kbl5733/work/github/deepflora/scripts/azure_from_index.sh # allow execution

/storage/home/kbl5733/work/github/deepflora/scripts/azure_from_index.sh \
-b https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_shpfl_2017 \
-o /storage/group/hlc30/default/data/deepflora/SHPFILES/naip_tiffs/pa_shpfl_2017

```

##### Download NAIP imagery

Here I use an R script to loop through a list of directories.

```
sbatch scripts/download_naip_sbatch.sh

```

#### State lat-lon max and min

In `Build_Dataset.py` the function `make_spatial_split` makes some assumptions about lat-long max and mins based on California. It doesn't look like these can be changed without changing the function defaults because the `make_dataset` that calls it and actually takes in the arguments from the user doesn't pass these options on.

Change the code in `build_dataset` to draw the max/min from the state shapefile. This is added immediately before the call to `make_spatial_split` in the definition of `make_dataset`. Then add argument definitions for `latmin`, `lonmin`, `latmax`, and `lonmax`.

```python
    minx, miny, maxx, maxy = shps.total_bounds
    daset = make_spatial_split(daset, latname, latmin = miny, latmax = maxy, lonmin = minx, lonmax = maxx)
```

#### Change `make_spatial_split`

The function `make_spatial_split` divides the state into cross validation sections but it assumes a long state like CA, so it is hard coded to use latitudinal bands at 1 degree intervals.

I need to change this function so that it: 1) defines the bands based on the size of the state, and 2) has the option to use longitudinal bands for wide states like PA. This also changes the `generate_split_polygons` function, which isn't necessary for making data, but is useful for visualization. The new functions are in `scripts/cv_polygons.py` in this repository.

Because I wanted this to be an option exposed in the `Build_Data.py` arguments, I added `cvaxis` flag with option `lat` or `lon` (default `lon`).

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

# write out means in json
os.makedirs(paths.MEANS, exist_ok=True)
with open(f, 'w') as fp:
    json.dump(daset_means, fp, indent=2)
```

Replace these lines:

```python
mean = torch.mean(torch.stack(torch.tensor(means)), dim=0)
std = torch.mean(torch.stack(torch.tensor(stds)), dim=0)
```

with

```python
mean = torch.stack([torch.tensor(m) for m in means]).mean(dim=0)
std  = torch.stack([torch.tensor(s) for s in stds]).mean(dim=0)
```

#### Add 2017 to exceptions in definition of `tiff_dset_name` in `make_dataset`

The PA 2017 dataset is 100cm resolution and so 2017 should be added in the line defining it in `make_dataset`

```python
tiff_dset_name = f"{state}_100cm_{year}" if str(year) in ['2012', '2014', '2017'] else f"{state}_060cm_{year}"

```


### Run `Build_data.py`:

In home directory:

```

# run with 26 cores using sbatch script at /storage/home/kbl5733/work/github/deepflora/scripts/build_data_parallel.sh

sbatch work/github/deepflora/scripts/build_data_parallel.sh

# if problem with different projections across state. Try:

sbatch work/github/deepflora/scripts/build_data_serial.sh
```

### Run Deepbiosphere

#### Debug

Inside of `Dataset.py` for class definition of `DeebioDataset`, change reference to `f"naip_{year}"` to `f"{state}_naip_{year}"` to be consistent with how the metadata is actually saved.

```python
        if metadata.dataset_means[f"{state}_naip_{year}"] is not None:    # added `{state}_` here
            self.mean = metadata.dataset_means[f"{state}_naip_{year}"]['means']
            self.std = metadata.dataset_means[f"{state}_naip_{year}"]['stds']

```

Inside `Run.py`, `train_model` function, add another `.datetime` to the call:

```python
    log_dir = f"{paths.RUNS}/{datetime.datetime.now().strftime('%Y_%m_%d_%H-%M-%S')}_{socket.gethostname()}_"
```

Also do this in the `train_and_test_model`.

#### run with p100 gpu and 26 cores using sbatch script

```
sbatch work/github/deepflora/scripts/run_deepbiosphere.sh

```

### Inference

```
# for help
# python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py --help

sbatch work/github/deepflora/scripts/run_inference.sh

```
