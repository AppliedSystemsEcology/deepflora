#!/bin/bash
#SBATCH --job-name=deepflora_pa_250
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=pa250_%j.out
#SBATCH --error=pa250_%j.err

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Make_Maps.py \
  --shape_pth states/pa.shp \
  --parent_dir pa_250 \
  --pred_year 2017 \
  --state pa \
  --pred_types ALPHA \
  --loss SAMPLE_AWARE_BCE \
  --exp_id initial \
  --band -1 \
  --loss SAMPLE_AWARE_BCE \
  --architecture DEEPBIOSPHERE \
  --epoch 7 \
  --batch_size 50 \
  --device 0 \
  --processes 8
