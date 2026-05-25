#!/bin/bash
#SBATCH --job-name=sdm_inf
#SBATCH --account=open
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=8:00:00
#SBATCH --output=logs/sdm_inf_%j.out
#SBATCH --error=logs/sdm_inf_%j.err

# $1 is the first positional argument passed to the script
# e.g.: sbatch spatcv_inference.sh ca
STATE=${1:?"Usage: sbatch spatcv_inference.sh <state> (e.g. ca, pa)"}

if [[ ! "$STATE" =~ ^(pa|ny)$ ]]; then
  echo "ERROR: state must be one of: pa or ny"
  exit 1
fi

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band -1 \
  --model rf \
  --dataset_name plants_${STATE}_2017 \
  --year 2017 \
  --state pa \
  --filename rf_${STATE}_2017_unif

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band -1 \
  --model maxent \
  --dataset_name plants_${STATE}_2017 \
  --year 2017 \
  --state pa \
  --filename maxent_${STATE}_2017_unif


# spatial cross-validation
for band in $(seq 0 9); do

  echo "Running inference on band ${band} of 9 for random forest..."
  python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band ${band} \
  --model rf \
  --dataset_name plants_${STATE}_2017 \
  --year 2017 \
  --state ${STATE} \
  --filename rf_${STATE}_2017_${band}

  echo "Running inference on band ${band} of 9 for maxent..."
  python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band ${band} \
  --model maxent \
  --dataset_name plants_${STATE}_2017 \
  --year 2017 \
  --state ${STATE} \
  --filename maxent_${STATE}_2017_${band}

done
