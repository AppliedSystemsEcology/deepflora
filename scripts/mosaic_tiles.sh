#!/bin/bash
#SBATCH --job-name=pymerge_ny
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=logs/pymerge_pa_%A.out
#SBATCH --error=logs/pymerge_pa_%A.err
#SBATCH --array=0

module load anaconda
source activate py-geo

IN_DIRS=(/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_albers_block/*)
OUT_DIR=/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_merge

mkdir -p "$OUT_DIR"

IN_DIR=${IN_DIRS[${SLURM_ARRAY_TASK_ID}]}

python /storage/home/kbl5733/work/github/deepflora/scripts/mosaic_tiles.py \
  "${IN_DIR}" \
  "${OUT_DIR}"
