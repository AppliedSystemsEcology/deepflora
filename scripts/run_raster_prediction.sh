#!/bin/bash
#SBATCH --job-name=deepflora_prediction
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=48:00:00
#SBATCH --output=logs/prediction_%j.out
#SBATCH --error=logs/prediction_%j.err

module load anaconda
source activate deepflora

declare -a files=("m_4007560_se_18_1_20170609.tif" "m_3907503_sw_18_1_20170609.tif" "m_3907623_ne_18_1_20170609.tif" "m_3907624_nw_18_1_20170519.tif" "m_3907624_ne_18_1_20170519.tif" "m_3907517_nw_18_1_20170519.tif" "m_3907517_ne_18_1_20170519.tif")

for i in "${files[@]}"
do
  python scripts/predict_raster.py "$i"
done
