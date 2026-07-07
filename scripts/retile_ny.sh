#!/bin/bash
#SBATCH --job-name=retile
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G
#SBATCH --time=12:00:00
#SBATCH --array=0-31
#SBATCH --output=logs/retile_%A.out
#SBATCH --error=logs/retile_%A.err

module load anaconda
conda activate py-geo

IN_DIRS=(/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_albers/*)
OUT_DIR=/storage/home/kbl5733/gstorage/data/deepflora/maps/ny_2017_albers_block

IN_DIR=${IN_DIRS[${SLURM_ARRAY_TASK_ID}]}
OUT_SUBDIR="${OUT_DIR}/$(basename "${IN_DIR}")"

echo "Task ${SLURM_ARRAY_TASK_ID}: processing ${IN_DIR}"

mkdir -p "$OUT_DIR"
mkdir -p "$OUT_SUBDIR"

# Loop over tiles
for TILE in "${IN_DIR}"/*.tif; do
  BASENAME=$(basename "$TILE")

  if [[ -s "${OUT_SUBDIR}/${BASENAME}" ]]; then
    echo "$BASENAME already exists"
  else
    echo "Retiling $BASENAME in $(basename "${IN_DIR}")"

    gdal_translate \
      -co TILED=YES \
      -co BLOCKXSIZE=256 \
      -co BLOCKYSIZE=256 \
      -co COMPRESS=LZW \
      -co BIGTIFF=YES \
      -co INTERLEAVE=BAND \
      -co SPARSE_OK=YES \
      -co NUM_THREADS=ALL_CPUS \
      "${TILE}" "${OUT_SUBDIR}/${BASENAME}"

    echo "Done: ${BASENAME}"
  fi

done
