#!/bin/bash
#SBATCH --job-name=proj_ny
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=logs/prjny_%A.out
#SBATCH --error=logs/prjny_%A.err

module load anaconda
source activate r-geo

Rscript scripts/project_rasters_loop.r ny
