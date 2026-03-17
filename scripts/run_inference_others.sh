#!/bin/bash
#SBATCH --job-name=others_inference
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=others_inference_%j.out
#SBATCH --error=others_inference_%j.err

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band -1 \
  --model RS_TRESNET \
  --exp_id tresnet \
  --loss SAMPLE_AWARE_BCE \
  --earlystopping mean_ROC_AUC \
  --batch_size 50 \
  --device 0 \
  --processes 8 \
  --year 2017 \
  --state pa \
  --filename tresnet_unif

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band -1 \
  --model BIOCLIM \
  --exp_id bioclim \
  --loss SAMPLE_AWARE_BCE \
  --earlystopping mean_ROC_AUC \
  --batch_size 50 \
  --device 0 \
  --processes 8 \
  --year 2017 \
  --state pa \
  --filename bioclim_unif
