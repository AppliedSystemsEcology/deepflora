#!/bin/bash
#SBATCH --job-name=merge_pa
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=500G
#SBATCH --time=72:00:00
#SBATCH --output=logs/mergepa_%A.out
#SBATCH --error=logs/mergepa_%A.err
#SBATCH --array=2

module load anaconda
source activate r-geo

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/merge_rasters_array.R /storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_albers /storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_merge
