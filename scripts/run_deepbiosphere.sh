#!/bin/bash
#SBATCH --job-name=db_pa
#SBATCH --account=hlc30_cr_default
#SBATCH --partition=standard
#SBATCH --gres=gpu:p100:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=224G
#SBATCH --time=48:00:00
#SBATCH --output=dbpa_%j.out
#SBATCH --error=dbpa_%j.err

module load anaconda
source activate deepflora

python /storage/home/kbl5733/src/deepbiosphere/src/deepbiosphere/Run.py \
  --year 2017 \
  --state pa \
  --dataset_name plants_pa_2017 \
  --datatype JOINT_NAIP_BIOCLIM \
  --band -1 \
  --lr .00001 \
  --epochs 12 \
  --model DEEPBIOSPHERE \
  --exp_id uniform \
  --loss SAMPLE_AWARE_BCE \
  --batchsize 150 \
  --dataset_type MULTI_SPECIES \
  --taxon_type spec_gen_fam \
  --device 0 \
  --processes 8
