#!/bin/bash
#SBATCH --job-name=deepflora_rf
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=sdm_rf_%j.out
#SBATCH --error=sdm_rf_%j.err

module load anaconda
source activate deepflora_r

# uniform test / train split
echo "Processing uniform train-test random forest"
Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --dset_name plants_pa --band unif_train_test --sdm rf --ncpu 26 --remakebkgd
if [ $? -ne 0 ]; then
    echo "ERROR: uniform train-test random forest failed"
fi

# spatial cross-validation
for band in $(seq 0 9); do
  echo "Processing band ${band} of 9 for random forest..."
  Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --dset_name plants_pa --band band_${band} --sdm rf --ncpu 26 --remakebkgd
  if [ $? -ne 0 ]; then
    echo "ERROR: band ${band} random forest failed"
  fi
done
