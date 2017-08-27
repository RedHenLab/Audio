#!/bin/bash
# script to train and test a speaker recognition system
#
# -------------------------------------------------

. /home/hxx124/myPython/virtualenv-1.9/ENV/bin/activate
module load ffmpeg


TRAIN="./output/audio"
TEST="../data_test/output/audio"
spk_train="overlap.json"
spk_test="overlap.json"
OUTDIR="./output"
#model="./output/recognizer.model"

python build_recognizer.py -d $TRAIN -s $spk_train -o $OUTDIR
python test_recognizer.py -d $TEST -s $spk_test -m $TRAIN
