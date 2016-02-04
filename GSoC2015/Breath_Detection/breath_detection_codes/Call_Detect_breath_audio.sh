#!/bin/bash

# This code is used to detect audio laughter segments in audio files when audio files are available

data_dir="$1"; # enter full path of the folder containing audio files
out_dir="$2";  # path where the output has to be saved

# Call the matlab code where audio file is processed to detect the laughter segments

matlab -nodesktop -nosplash -nodisplay -nojvm -r "Detect_breath $data_dir $out_dir"
