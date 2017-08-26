#!/bin/bash
#
# Test forced alignment
#
# ----------------------------

SCRIPT=`basename $0`

# Help screen
if [ "$1" = "-h" -o "$1" = "--help" -o "$1" = "help" ] ; then
  echo -e "\n\tTest gentle, the forced aligner."
  echo -e "\n\tSyntax:"
  echo -e "\n\t\t$SCRIPT <filename>"
  echo -e "\n\tExample:"
  echo -e "\n\t\t$SCRIPT 2014-03-27_0300_US_CNN_Jake_Tapper_Topical_News"
  echo -e "\n\tThe script handles both mp4 and wav files.\n"
   exit
fi

# Input file
if [ -z "$1" ]
  then echo -e "\n\tPlease enter the name of the audio file to align\n" ; exit
  else FIL="$1"
fi

# Load modules
module load python/2.7.10
module load ffmpeg/2.8.2
module load gcc/4.7.3

# User specific aliases and functions (from ~/.bashrc)
#PATH=$PATH:$HOME/myPython/ptyprocess/ptyprocess
#PATH=$PATH:$HOME/kaldi/src/*bin:$HOME/kaldi/tools/openfst/src/bin:$HOME/kaldi/src/tools/openfst/bin:$HOME/.local/lib/python2.7/site-packages/notebook:$HOME/.local/lib/python2.7/site-packages/IPython
#PATH=$PATH:$HOME/.local/bin
#PATH=$PATH:$HOME/Pipeline/kaldi-trunk/src/*bin
#PATH=$PATH:$HOME/Pipeline/kaldi-trunk/tools/openfst-1.3.4/src/bin
#PATH=$PATH:$HOME/Pipeline/kaldi-trunk/tools/irstlm/bin
export PYTHONPATH=""
export PYTHONPATH="${PYTHONPATH}:$HOME/myPython/virtualenv-1.9/ENV/lib/python2.7/site-packages/"
export PYTHONPATH="${PYTHONPATH}:/usr/local/lapack/3.5.0"
export PYTHONPATH="${PYTHONPATH}:/usr/local/blas/2015"
export PYTHONPATH="${PYTHONPATH}:/usr/local"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/hdf5/1.8.11/lib:/usr/local/cuda-7.0/lib64:/usr/local/python/2.7.8/lib:/usr/local/boost/1_58_0/lib:/usr/local/yaml/0.1.5/lib:/usr/local/munge/lib:/usr/local/slurm/lib:/usr/local/openmpi/1.8.3/lib:/usr/local/intel/2013/composer_xe_2013.5.192/mkl/lib/intel64:/usr/local/intel/2013/composer_xe_2013.5.192/compiler/lib/intel64:/usr/local/munge/lib:/usr/local/slurm/lib::/usr/local/lib:$HOME/.local/lib
alias qjup="kill $(pgrep jupyter)"


PATH=$PATH:$HOME/Gentle/gentle
PYTHONPATH="${PYTHONPATH}:$HOME/Gentle/gentle"

#echo $PATH
#echo $PYTHONPATH #; exit

# text extension
if [ -z "$2" ]
  then textext=chevron.tpt
  else textext="$2"
fi

# out extension
if [ -z "$4" ]
  then outext=align.jsonl
  else outext="$4"
fi


# Base directory
if [ -z "$5" ]
  then DIR=$HOME/data_tmp/input
  else DIR="$5"
fi

# Script directory
if [ -z "$6" ]
  then TXTDIR=$HOME/data_tmp/input
  else TXTDIR="$6"
fi

# Out directory
if [ -z "$3" ]
  then OUTDIR=$HOME/data_tmp/output/align
  else OUTDIR="$3"
fi


if [ ! -d "$OUTDIR" ]; then
  mkdir $OUTDIR
fi

# Gentle directory
#GENDIR=$HOME/Gentle/gentle
GENDIR=/home/mxp523/audio_pipeline_dev/gentle_lq

# Check for input
if [ -f $DIR/$FIL.wav ] ; then INFIL=$DIR/$FIL.wav
  elif [ -f $DIR/$FIL.mp4 ] ; then INFIL=$DIR/$FIL.mp4
    elif [ -f $DIR/$FIL.mp3 ] ; then INFIL=$DIR/$FIL.mp3
      else echo -e "\n\tUnable to locate the audio or video input file.  \n" ; exit
fi

# Run aligner with JSON lines output
#python $GENDIR/gen_spk.py -o $OUTDIR/$FIL.$outext -f jsonl $INFIL $TXTDIR/$FIL.$textext 
python $GENDIR/align.py -o $OUTDIR/$FIL.$outext $INFIL $TXTDIR/$FIL.$textext 

# Receipt
if [ -f $OUTDIR/$FIL.align.jsonl ]
  then echo -e "\n\tThe output is available in $OUTDIR/$FIL.$outext\n"
  else echo -e "\n\tThe forced alignment failed -- run debug\n"
fi

# Extract speaker information from the .tpt file
#if [ -f $DIR/$FIL.tpt ] 
#then 
#  grep -o "|NER_01|Person.*" $DIR/$FIL.tpt > $DIR/speaker_list
  # Run the converterto locate speaker turns and insert speaker info back
#  python align2spk.py -o $HOME/data_tmp/output/spk/$FIL.align.spk $OUTDIR/$FIL.align.jsonl
#fi

