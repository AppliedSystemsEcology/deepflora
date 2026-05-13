#!/bin/bash
#SBATCH --job-name=db_inf
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=inf_%j.out
#SBATCH --error=inf_%j.err

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
  --model DEEPBIOSPHERE \
  --exp_id initial \
  --loss SAMPLE_AWARE_BCE \
  --earlystopping mean_ROC_AUC \
  --batch_size 50 \
  --device 0 \
  --processes 25 \
  --year 2017 \
  --state pa \
  --filename initial_db
