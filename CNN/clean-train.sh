#!/bin/bash
# main script to clean the training data for speaker recognition
#
# -------------------------------------------------

. /home/hxx124/myPython/virtualenv-1.9/ENV/bin/activate
module load ffmpeg


DATADIR="./output/audio"

for speaker_path in $DATADIR/*; do
    if [ -d "$speaker_path" ]; then
        speaker=${speaker_path##*/}
        echo "detecting outliers in $speaker"
        # Run the outlier detection
        python detect_outlier.py -i $DATADIR/ -s $speaker
    fi
done
