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
#SBATCH --output=maxent_%j.out
#SBATCH --error=maxent_%j.err

module load anaconda
source activate deepflora_r

# uniform test / train split
echo "Processing uniform train-test random forest"
Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --band unif_train_test --sdm rf --ncpu 26
if [ $? -ne 0 ]; then
    echo "ERROR: uniform train-test random forest failed"
fi

echo "Processing uniform train-test maxent"
Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --dset_name  --band unif_train_test --sdm maxent --ncpu 26
if [ $? -ne 0 ]; then
    echo "ERROR: uniform train-test maxent failed"
fi


# spatial cross-validation band example
for band in $(seq 0 11); do
  echo "Processing band ${band} of 11 for random forest..."
  Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --band band_${band} --sdm rf --ncpu 26
  if [ $? -ne 0 ]; then
    echo "ERROR: band ${band} random forest failed"
  fi
done

for band in $(seq 0 11); do
  echo "Processing band ${band} of 11 for maxent..."
  Rscript src/deepbiosphere/src/deepbiosphere/Maxent_RF_bioclim.R --band band_${band} --sdm maxent --ncpu 26
  if [ $? -ne 0 ]; then
    echo "ERROR: band ${band} maxent failed"
  fi
done
