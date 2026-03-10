#!/bin/bash

JOB1=$(sbatch --parsable work/github/deepflora/scripts/run_rf.sh)
echo "Submitted random forest models as $JOB1"
JOB2=$(sbatch --parsable --dependency=afterok:$JOB1 work/github/deepflora/scripts/run_maxent.sh)
echo "Submitted maxent models as $JOB2, waiting on $JOB1"
