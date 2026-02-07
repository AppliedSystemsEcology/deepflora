#!/bin/bash
#SBATCH --job-name=deepflora_build_data
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=28
#SBATCH --mem=224G
#SBATCH --time=06:00:00
#SBATCH --output=build_data_%j.out
#SBATCH --error=build_data_%j.err

module load anaconda
source activate deepflora

python src/deepbiosphere/src/deepbiosphere/Build_Data.py \
  --dset_path /storage/group/hlc30/default/data/deepflora/OCCS/plant_2015_2025_USA_39_1_acq2026_1_27.csv \
  --daset_id plants_pa \
  --sep '\t' \
  --year 2017 \
  --state pa \
  --calculate_means \
  --threshold 500 \
  --add_images \
  --parallel 26 \
  --idCol gbifID