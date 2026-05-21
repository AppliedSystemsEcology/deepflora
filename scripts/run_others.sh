#!/bin/bash
#SBATCH --job-name=deepflora_others
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=9
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=logs/run_others_%j.out
#SBATCH --error=logs/run_others_%j.err

# $1 is the first positional argument passed to the script
# e.g.: sbatch spatcv_inference.sh ca
STATE=${1:?"Usage: sbatch spatcv_inference.sh <state> (e.g. ca, pa)"}

if [[ ! "$STATE" =~ ^(pa|ny)$ ]]; then
  echo "ERROR: state must be one of: pa or ny"
  exit 1
fi


module load anaconda
source activate deepflora_r

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state ${STATE} \
  --dataset_name plants_${STATE}_2017 \
  --datatype NAIP \
  --band -1 \
  --lr .00001 \
  --epochs 12 \
  --model RS_TRESNET \
  --exp_id tresnet_${STATE}_2017 \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state ${STATE} \
  --dataset_name plants_${STATE}_2017 \
  --datatype BIOCLIM \
  --band -1 \
  --lr .00001 \
  --epochs 12 \
  --model BIOCLIM_MLP \
  --exp_id bioclim_${STATE}_2017 \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8
