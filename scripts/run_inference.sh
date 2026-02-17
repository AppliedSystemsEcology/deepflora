#!/bin/bash
#SBATCH --job-name=deepflora_inference
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=rundb_%j.out
#SBATCH --error=rundb_%j.err

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
