#!/bin/bash
#SBATCH --job-name=retile
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --array=1-24
#SBATCH --output=logs/retile_%A_%a.out
#SBATCH --error=logs/retile_%A_%a.err

module load anaconda
conda activate py-geo

IN_DIR=/storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_merge
OUT_DIR=/storage/home/kbl5733/gstorage/data/deepflora/maps/pa_2017_merge_block

mkdir -p $OUT_DIR

# Get the Nth tile
TILE=$(ls ${IN_DIR}/*.tif | sed -n "${SLURM_ARRAY_TASK_ID}p")
BASENAME=$(basename $TILE)

echo "Retiling $BASENAME"

gdal_translate \
  -co TILED=YES \
  -co BLOCKXSIZE=256 \
  -co BLOCKYSIZE=256 \
  -co COMPRESS=LZW \
  -co BIGTIFF=YES \
  -co INTERLEAVE=BAND \
  ${TILE} ${OUT_DIR}/${BASENAME}

echo "Done: ${BASENAME}"
