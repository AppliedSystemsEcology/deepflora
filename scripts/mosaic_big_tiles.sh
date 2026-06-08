#!/bin/bash
#SBATCH --job-name=pymerge_pa
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=logs/pymerge_pa_%A.out
#SBATCH --error=logs/pymerge_pa_%A.err

module load anaconda
source activate py-geo

python /storage/home/kbl5733/work/github/deepflora/scripts/mosaic_big_tiles.py \
  /storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_merge_block \
  /storage/home/kbl5733/gstorage/data/deepflora/maps/out
