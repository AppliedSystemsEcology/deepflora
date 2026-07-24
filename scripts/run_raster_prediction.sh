#!/bin/bash
#SBATCH --job-name=deepflora_prediction
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=prediction_%j.out
#SBATCH --error=prediction_%j.err

module load anaconda
source activate deepflora

python work/github/deepflora/scripts/predict_raster.py
