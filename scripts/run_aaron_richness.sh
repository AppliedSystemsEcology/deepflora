#!/bin/bash
#SBATCH --job-name=df_aaron_rich
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=72:00:00
#SBATCH --output=logs/dfarich_%j.out
#SBATCH --error=logs/dfarich_%j.err

module load anaconda
source activate r-geo

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/aaron/make_richrast.R
