#!/bin/bash
#SBATCH --job-name=db_runcv
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=dbcv_%A_%a.out
#SBATCH --error=dbcv_%A_%a.err
#SBATCH --array=0-9%1

# $1 is the first positional argument passed to the script
# e.g.: sbatch spatcv_inference.sh ca
STATE=${1:?"Usage: sbatch spatcv_inference.sh <state> (e.g. ca, pa)"}

if [[ ! "$STATE" =~ ^(pa|ny)$ ]]; then
  echo "ERROR: state must be one of: pa or ny"
  exit 1
fi

module load anaconda
source activate deepflora

# spatial cross-validation
echo "Processing band ${SLURM_ARRAY_TASK_ID} of 9 for deepbiosphere..."
python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state ${STATE} \
  --dataset_name plants_${STATE}_2017 \
  --datatype JOINT_NAIP_BIOCLIM \
  --band ${SLURM_ARRAY_TASK_ID} \
  --lr .00001 \
  --epochs 12 \
  --model DEEPBIOSPHERE \
  --exp_id db_${STATE}_band_${SLURM_ARRAY_TASK_ID} \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8

if [ $? -ne 0 ]; then
  echo "ERROR: band ${SLURM_ARRAY_TASK_ID} deepbiosphere failed"
fi
