#!/bin/bash
###############################################
# I/P: BIG_FILE.wav
# O/P: data_for_TTS/wav/*.wav
###############################################

expt_name=$1
BIG_FILE=$2

echo "Running scripts/chunk_BIG_FILE/chunk_big_file.sh ..."
echo ""; echo ""; echo ""

rm scripts/chunk_BIG_FILE/dur_info.txt; touch scripts/chunk_BIG_FILE/dur_info.txt

# split $BIG_FILE at points where sil_dur>=0.7sec. 
sox $BIG_FILE data_for_Alignment/wav/${expt_name}_.wav silence 1 0.2 1% 1 1.0 1% : newfile : restart

for i in $(ls data_for_Alignment/wav/*.wav); do
  echo "$i"
  fname=`basename $i .wav`
  $ESTDIR/bin/ch_wave -F 16000 -c 0 $i -otype riff -scaleN 0.65 -o $fname.wav
  mv $fname.wav data_for_Alignment/wav
done

ls data_for_Alignment/wav/${expt_name}*.wav | sed 's/\(.*\)\/\(.*\).wav/\2 \1\/\2.wav/' > scripts/chunk_BIG_FILE/wavlist.scp
wav-to-duration scp:scripts/chunk_BIG_FILE/wavlist.scp ark,t:scripts/chunk_BIG_FILE/dur_info.txt >& /dev/null
avg_dur=`cat scripts/chunk_BIG_FILE/dur_info.txt | awk '{ sum += $2; n++ } END { if (n > 0) print sum / n; }'`
echo "Avg. duration of chunks = $avg_dur"
cat scripts/chunk_BIG_FILE/dur_info.txt | sort -k2 -nr | head
