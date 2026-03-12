#!/bin/bash
#SBATCH --job-name=deepflora_maxent
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=sdm_maxent_%j.out
#SBATCH --error=sdm_maxent_%j.err

module load anaconda
source activate deepflora_r

echo "Processing uniform train-test maxent"
Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --dset_name plants_pa --band unif_train_test --sdm maxent --ncpu 26
if [ $? -ne 0 ]; then
    echo "ERROR: uniform train-test maxent failed"
fi


for band in $(seq 0 9); do
  echo "Processing band ${band} of 9 for maxent..."
  Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --dset_name plants_pa --band band_${band} --sdm maxent --ncpu 26
  if [ $? -ne 0 ]; then
    echo "ERROR: band ${band} maxent failed"
  fi
done
