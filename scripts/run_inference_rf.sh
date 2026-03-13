#!/bin/bash
#SBATCH --job-name=rf_inference
#SBATCH --account=kbl5733
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=8:00:00
#SBATCH --output=rf_inference_%j.out
#SBATCH --error=rf_inference_%j.err

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band -1 \
  --model rf \
  --dataset_name plants_pa \
  --year 2017 \
  --state pa \
  --filename rf_unif
