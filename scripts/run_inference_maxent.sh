#!/bin/bash
#SBATCH --job-name=maxent_inference
#SBATCH --account=open
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=8:00:00
#SBATCH --output=me_inference_%j.out
#SBATCH --error=me_inference_%j.err

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Inference.py \
  --band -1 \
  --model maxent \
  --dataset_name plants_pa \
  --year 2017 \
  --state pa \
  --filename maxent_unif
