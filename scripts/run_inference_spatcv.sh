#!/bin/bash
#SBATCH --job-name=spatcv_inference
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=spatcv_inference_%A_%a.out
#SBATCH --error=spatcv_inference_%A_%a.err
#SBATCH --array=0-9%1

module load anaconda
source activate deepflora

# spatial cross-validation
echo "Inference for band ${SLURM_ARRAY_TASK_ID} of 9 for deepbiosphere..."
python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band ${SLURM_ARRAY_TASK_ID} \
  --model DEEPBIOSPHERE \
  --exp_id band_${SLURM_ARRAY_TASK_ID} \
  --loss SAMPLE_AWARE_BCE \
  --epoch 7 \
  --batch_size 50 \
  --device 0 \
  --processes 8 \
  --year 2017 \
  --state pa \
  --filename db_band_${SLURM_ARRAY_TASK_ID}

if [ $? -ne 0 ]; then
  echo "ERROR: band ${SLURM_ARRAY_TASK_ID} deepbiosphere failed"
fi

# echo "Inference for band ${SLURM_ARRAY_TASK_ID} of 9 for random forest..."
# python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
#   --band ${SLURM_ARRAY_TASK_ID} \
#   --model rf \
#   --dataset_name plants_pa \
#   --year 2017 \
#   --state pa \
#   --filename rf_band_${SLURM_ARRAY_TASK_ID}
#
# if [ $? -ne 0 ]; then
#   echo "ERROR: band ${SLURM_ARRAY_TASK_ID} random forest failed"
# fi
#
# echo "Inference for band ${SLURM_ARRAY_TASK_ID} of 9 for maxent..."
# python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
#   --band ${SLURM_ARRAY_TASK_ID} \
#   --model maxent \
#   --dataset_name plants_pa \
#   --year 2017 \
#   --state pa \
#   --filename maxent_band_${SLURM_ARRAY_TASK_ID}
#
# if [ $? -ne 0 ]; then
#   echo "ERROR: band ${SLURM_ARRAY_TASK_ID} maxent failed"
# fi

