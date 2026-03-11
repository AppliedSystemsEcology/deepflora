#!/bin/bash
#SBATCH --job-name=deepflora_others
#SBATCH --account=hlc30_p100_default
#SBATCH --partition=sla-prio
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=run_others_%j.out
#SBATCH --error=run_others_%j.err

module load anaconda
source activate deepflora_r

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state pa \
  --dataset_name plants_pa \
  --datatype NAIP \
  --band -1 \
  --lr .00001 \
  --epochs 12 \
  --model RS_TRESNET \
  --exp_id tresnet \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state pa \
  --dataset_name plants_pa \
  --datatype BIOCLIM \
  --band -1 \
  --lr .00001 \
  --epochs 12 \
  --model BIOCLIM_MLP \
  --exp_id bioclim \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8
