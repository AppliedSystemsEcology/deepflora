#!/bin/bash
#SBATCH --job-name=deepflora_sdm
#SBATCH --account=open
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=224G
#SBATCH --time=8:00:00
#SBATCH --output=logs/sdm_%j.out
#SBATCH --error=logs/sdm_%j.err

# $1 is the first positional argument passed to the script
# e.g.: sbatch spatcv_inference.sh ca
STATE=${1:?"Usage: sbatch spatcv_inference.sh <state> (e.g. ca, pa)"}

if [[ ! "$STATE" =~ ^(pa|ny)$ ]]; then
  echo "ERROR: state must be one of: pa or ny"
  exit 1
fi


module load anaconda
source activate deepflora_r

# uniform test / train split
echo "Processing uniform train-test random forest"
Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R \
  --dset_name plants_${STATE}_2017 \
  --band unif_train_test \
  --sdm rf \
  --ncpu 26 \
  --remakebkgd

if [ $? -ne 0 ]; then
    echo "ERROR: uniform train-test random forest failed"
fi

echo "Processing uniform train-test maxent"
Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R \
  --dset_name plants_${STATE}_2017 \
  --band unif_train_test \
  --sdm maxent \
  --ncpu 26

if [ $? -ne 0 ]; then
    echo "ERROR: uniform train-test maxent failed"
fi

# spatial cross-validation
for band in $(seq 0 9); do

  echo "Processing band ${band} of 9 for random forest..."
  Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R \
    --dset_name plants_${STATE}_2017 \
    --band band_${band} \
    --sdm rf \
    --ncpu 26 \
    --remakebkgd
  if [ $? -ne 0 ]; then
    echo "ERROR: band ${band} random forest failed"
  fi

  echo "Processing band ${band} of 9 for maxent..."
  Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R \
    --dset_name plants_${STATE}_2017 \
    --band band_${band} \
    --sdm maxent \
    --ncpu 26
  if [ $? -ne 0 ]; then
    echo "ERROR: band ${band} maxent failed"
  fi

done
