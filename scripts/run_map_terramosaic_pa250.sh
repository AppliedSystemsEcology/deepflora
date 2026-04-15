#!/bin/bash
#SBATCH --job-name=terra_pa_250
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=ter_pa250_%j.out
#SBATCH --error=ter_pa250_%j.err

module load anaconda
source activate r-gis

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/merge_rasters.R
