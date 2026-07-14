#!/bin/bash
#SBATCH --job-name=pymerge_ny
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=40G
#SBATCH --time=72:00:00
#SBATCH --output=logs/pymerge_ny_%A.out
#SBATCH --error=logs/pymerge_ny_%A.err
#SBATCH --array=0-31

module load anaconda
source activate py-geo

IN_DIRS=(/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_albers_block/*)
OUT_DIR=/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_merge

mkdir -p "$OUT_DIR"

IN_DIR=${IN_DIRS[${SLURM_ARRAY_TASK_ID}]}

python /storage/home/kbl5733/work/github/deepflora/scripts/mosaic_tiles.py \
  "${IN_DIR}" \
  "${OUT_DIR}"
