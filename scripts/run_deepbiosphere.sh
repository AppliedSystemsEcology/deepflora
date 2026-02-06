#!/bin/bash
#SBATCH --job-name=deepflora_run
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=26
#SBATCH --mem=224G
#SBATCH --time=06:00:00
#SBATCH --output=rundb_%j.out
#SBATCH --error=rundb_%j.err

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state pa \
  --dataset_name plants_pa \
  --datatype JOINT_NAIP_BIOCLI \
  --band -1 \
  --lr .00001 \
  --epochs 12 \
  --model DEEPBIOSPHERE \
  --exp_id initial \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 26
