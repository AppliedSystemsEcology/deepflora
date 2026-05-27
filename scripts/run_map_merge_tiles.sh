#!/bin/bash
#SBATCH --job-name=merge_pa
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=800G
#SBATCH --time=72:00:00
#SBATCH --output=logs/mergepa_%j.out
#SBATCH --error=logs/mergepa_%j.err

module load anaconda
source activate r-geo

Rscript /storage/home/kbl5733/work/github/deepflora/scripts/merge_rasters.R /storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_albers "Cercis canadensis" /storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_merge
