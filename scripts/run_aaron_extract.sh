#!/bin/bash
#SBATCH --job-name=df_aaron_extr
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=basic
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=72:00:00
#SBATCH --output=logs/dfaextr_%j.out
#SBATCH --error=logs/dfaextr_%j.err

module load anaconda
source activate deepflora

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/aaron/extract30m.R
