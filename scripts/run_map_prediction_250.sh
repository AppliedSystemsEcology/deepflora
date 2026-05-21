#!/bin/bash
#SBATCH --job-name=df_250
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=logs/df_250_%j.out
#SBATCH --error=logs/df_250_%j.err

# $1 is the first positional argument passed to the script
# e.g.: sbatch spatcv_inference.sh ca
STATE=${1:?"Usage: sbatch spatcv_inference.sh <state> (e.g. ca, pa)"}

if [[ ! "$STATE" =~ ^(pa|ny)$ ]]; then
  echo "ERROR: state must be one of: pa or ny"
  exit 1
fi

module load anaconda
source activate deepflora

export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Make_Maps.py \
  --shape_pth states/${STATE}.shp \
  --parent_dir ${STATE}_250_2017 \
  --pred_year 2017 \
  --state ${STATE} \
  --pred_types RAW \
  --loss SAMPLE_AWARE_BCE \
  --exp_id db_${STATE}_2017 \
  --band -1 \
  --loss SAMPLE_AWARE_BCE \
  --architecture DEEPBIOSPHERE \
  --epoch 8 \
  --batch_size 25 \
  --device 0 \
  --processes 1
