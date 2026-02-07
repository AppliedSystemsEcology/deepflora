#!/bin/bash
#SBATCH --job-name=download_naip
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=224G
#SBATCH --time=06:00:00
#SBATCH --output=dlnaip_%j.out
#SBATCH --error=dlnaip_%j.err

module load anaconda
source activate r-gis

Rscript scripts/download_naip_pa.R
