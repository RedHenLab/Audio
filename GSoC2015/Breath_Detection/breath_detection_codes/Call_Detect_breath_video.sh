#!/bin/bash

# This code is used to call the python code to extract audio from video files and then detect laughtert regions in the given audio file

data_dir="$1"; # enter full path of the folder containing video files
out_dir="$2";  # path where the audio files has to be saved

# call the python code to extract audio from the given video file

python Audio_from_video.py $data_dir $out_dir

# call matlab code to detect laughter segments in the given audio file
# The detected laughter segments are written to a text file which is saved in the same folder where audio files are saved.

matlab -nodesktop -nosplash -nodisplay -nojvm -r "Detect_breath $out_dir $out_dir"
