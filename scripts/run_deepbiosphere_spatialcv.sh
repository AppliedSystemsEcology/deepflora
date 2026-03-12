#!/bin/bash
#SBATCH --job-name=deepflora_spatialcv
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=dbspatialcv_%A_%a.out
#SBATCH --error=dbspatialcv_%A_%a.err
#SBATCH --array=0-9%1

module load anaconda
source activate deepflora

# spatial cross-validation
echo "Processing band ${SLURM_ARRAY_TASK_ID} of 9 for deepbiosphere..."
python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state pa \
  --dataset_name plants_pa \
  --datatype JOINT_NAIP_BIOCLIM \
  --band ${SLURM_ARRAY_TASK_ID} \
  --lr .00001 \
  --epochs 12 \
  --model DEEPBIOSPHERE \
  --exp_id initial \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8

if [ $? -ne 0 ]; then
  echo "ERROR: band ${SLURM_ARRAY_TASK_ID} deepbiosphere failed"
fi
