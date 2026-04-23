#!/bin/bash
#SBATCH --job-name=mosaic_array
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=56G
#SBATCH --time=72:00:00
#SBATCH --output=mosaic_%A_%a.out
#SBATCH --error=mosaic_%A_%a.err
#SBATCH --array=1-24%4                ### Array index

module load anaconda
source activate r-gis

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/merge_rasters_array.R
