#!/bin/bash
#SBATCH --job-name=mosaic_array
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=9G
#SBATCH --time=48:00:00
#SBATCH --output=mosaic_%j.out
#SBATCH --error=mosaic_%j.err
#SBATCH --array=1-24                ### Array index

module load anaconda
source activate r-gis

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/merge_rasters_array.R
