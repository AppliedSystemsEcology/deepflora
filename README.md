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

### make the target directories
```
mkdir /storage/group/hlc30/default/data/deepflora/{OCCS,SHPFILES,MODELS,IMAGES,RASTERS,BASELINES,RESULTS,MISC,DOCS,SCRATCH,RUNS}
```

## Build training and testing dataset

https://github.com/moiexpositoalonsolab/Deepbiosphere?tab=readme-ov-file#building-the-training-and-testing-dataset-for-deepbiosphere

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

### Download GBIF data

#### Set up GBIF

Set up a `.netrc` file, instructions in [the repository](https://github.com/moiexpositoalonsolab/deepbiosphere?tab=readme-ov-file#setting-up-access-on-gbif).

#### Run `Download_GBIF_Data.py

```
# python src/deepbiosphere/Download_GBIF_Data.py --gbif_user [your_username] --gbif_email [your_gbif_email] --organism plant --start_date 2015 --end_date 2022

# Pennsylvania
python src/deepbiosphere/src/deepbiosphere/Download_GBIF_Data.py --gbif_user neivkli --gbif_email likevin@umich.edu --organism plant --start_date 2015 --end_date 2025 --area "USA.39_1"

# New York
python src/deepbiosphere/src/deepbiosphere/Download_GBIF_Data.py --gbif_user neivkli --gbif_email likevin@umich.edu --organism plant --start_date 2015 --end_date 2025 --area "USA.33_1"

```

## Run `Build_data.py`:

In home directory:

```

# run with 26 cores using sbatch script at /storage/home/kbl5733/work/github/deepflora/scripts/build_data_parallel.sh

sbatch work/github/deepflora/scripts/build_data_parallel.sh

# if problem with different projections across state. Try:

sbatch work/github/deepflora/scripts/build_data_serial.sh
```

## Run Deepbiosphere

Run with p100 gpu and 26 cores using sbatch script

```
sbatch work/github/deepflora/scripts/run_deepbiosphere.sh

```

### Inference

```
# for help
# python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py --help

sbatch work/github/deepflora/scripts/run_inference.sh

```
