#!/bin/bash
#SBATCH -N 1
#SBATCH -c 10
#SBATCH --mem-per-cpu=3G
#SBATCH --time=0-10:30:00
#SBATCH --output=data-prep.log
#SBATCH --mail-user=
#SBATCH --mail-type=ALL
#SBATCH --job-name="data-prep"
#
#
#


# The file that contains the list
./process-list.sh tmp-list
