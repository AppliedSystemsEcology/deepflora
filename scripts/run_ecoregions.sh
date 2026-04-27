#!/bin/bash
#SBATCH --job-name=eco_ny
#SBATCH --account=open
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=econy_%j.out
#SBATCH --error=econy_%j.err

module load anaconda
source activate r-gis

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/ecoregions_ny.R
