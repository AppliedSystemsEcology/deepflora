#!/bin/bash
#SBATCH --job-name=download_naip
#SBATCH --account=open
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=48:00:00
#SBATCH --output=dlnaip_%j.out
#SBATCH --error=dlnaip_%j.err
#SBATCH --array=1-32%28                ### Array index

module load anaconda
source activate r-gis

Rscript scripts/download_naip_array.R
