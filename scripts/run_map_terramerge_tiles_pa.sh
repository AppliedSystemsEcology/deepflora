#!/bin/bash
#SBATCH --job-name=merge_pa
#SBATCH --account=open
#SBATCH --partition=himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=1000G
#SBATCH --time=1:00:00
#SBATCH --output=mergepa_%j.out
#SBATCH --error=mergepa_%j.err

module load anaconda
source activate r-gis

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/merge_rasters.R
