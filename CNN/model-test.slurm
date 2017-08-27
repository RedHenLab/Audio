#!/bin/bash
#SBATCH -N 1
#SBATCH -c 10
#SBATCH --mem-per-cpu=3G
#SBATCH --time=0-20:30:00
#SBATCH --output=test-model.log
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH --job-name="test-model"
#
#
#


# run the script
./train_test.sh
