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
#SBATCH --error=logs/sdm_inf_%A_%a.err
#SBATCH --array=0-10

# $1 is the first positional argument passed to the script
# e.g.: sbatch spatcv_inference.sh ca
STATE=${1:?"Usage: sbatch spatcv_inference.sh <state> (e.g. ca, pa)"}

if [[ ! "$STATE" =~ ^(pa|ny)$ ]]; then
  echo "ERROR: state must be one of: pa or ny"
  exit 1
fi

echo "This is the state ${STATE}"

BAND=${SLURM_ARRAY_TASK_ID}

if [[ "$SLURM_ARRAY_TASK_ID" -eq 10 ]]; then
  BAND=-1
fi

module load anaconda
source activate deepflora

echo "Running inference on band ${BAND} for random forest..."
python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band ${BAND} \
  --model rf \
  --dataset_name plants_${STATE}_2017 \
  --year 2017 \
  --state ${STATE} \
  --filename rf_${STATE}_2017

echo "Running inference on band ${BAND} for maxent..."
python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band ${BAND} \
  --model maxent \
  --dataset_name plants_${STATE}_2017 \
  --year 2017 \
  --state ${STATE} \
  --filename maxent_${STATE}_2017
