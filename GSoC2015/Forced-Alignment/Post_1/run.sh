#!/bin/bash
#########################################################################################
#I/P: BIGFILE.wav
#O/P: wav/, etc/txt.done.data, lab_wd_level/, lab_phn_level/ inside data_for_TTS/ folder
#########################################################################################

BIG_FILE="../audio_0001.wav"
expt_name="ForcedAlignment"
spk_gender="m" 
Ngram=1 
num_free_CPUs=20             
adapt="yes"


rm -rf data_for_Alignment/
mkdir -p data_for_Alignment/wav data_for_TTS/etc 
mkdir -p data_for_Alignment/lab_wd_level          # contain lab_info  + 
mkdir -p data_for_Alignment/lab_phn_level         # confidence scores


sh scripts/chunk_BIG_FILE/chunk_big_file.sh $expt_name $BIG_FILE


cd scripts/run_kaldi
sh run_kaldi.sh $expt_name $spk_gender $Ngram $num_free_CPUs $adapt
