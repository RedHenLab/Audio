#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=10:10:00
#SBATCH --gres=gpu:2
#SBATCH --cpus-per-task=6
#SBATCH -p gpufermi
#SBATCH -J diaria

export CUDA_VISIBLE_DEVICES=`gpu-free`

echo "Your job is running in:"
cat $SLURM_NPROCS*$SLURM_NNODES



for i in `ls -d -1 $PWD/test_cfg/*` ; do
        cp -r cluster.py $i $PFSDIR
	cd $PFSDIR
	python cluster.py -c $i
done


cp * $SLURM_SUBMIT_DIR
