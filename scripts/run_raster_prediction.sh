#!/bin/bash
#SBATCH --job-name=df_pred_aaron
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=logs/dfpredaaron_%j.out
#SBATCH --error=logs/dfpredaaron_%j.err

module load anaconda
source activate deepflora

mapfile -t files < scripts/aaron/filenames.txt
total=${#files[@]}

for i in "${files[@]}"
do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing file $((i+1)) of $total: ${files[$i]}"
  python scripts/predict_raster.py "$i" ny
done
