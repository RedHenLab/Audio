#!/bin/bash
# main script to prepare training data for speaker recognition
#
# -------------------------------------------------

# Help screen
if [ "$1" = "-h" -o "$1" = "--help" -o "$1" = "help" ] ; then
  echo -e "\n\tSyntax: ./`basename $0` <filename>"
  echo -e "\n\tGet a stripped tpt file and its video from cartago."
  echo -e "\n\tExample (the script strips any extension):"
  echo -e "\n\t\t./`basename $0` 2017-03-24_1700_US_CNN_Wolf"
  echo -e "\n\tYou can use a loop for a list of files: for F in \`cat tpt-filelist\` ; do ./`basename $0` \$F ; done\n"
  exit
fi

INDIR="./input"
OUTDIR="./output"

mkdir -p $INDIR
mkdir -p $OUTDIR/spk

# load required modules
module load ffmpeg
. /home/hxx124/myPython/virtualenv-1.9/ENV/bin/activate

# Strip any extensions
FIL=${1%%.*}


# Get the video and tpt files from cartago
./get.sh $FIL


# Strip off redundant info from the tpt file
./strip-tpt.sh $FIL.tpt $INDIR 

# Clean up non utf-8 characters
iconv -f utf-8 -t utf-8 -c $INDIR/$FIL.chevron.tpt > $INDIR/$FIL.tmp
mv -f $INDIR/$FIL.tmp $INDIR/$FIL.chevron.tpt

# Run Gentle Alignment on this audio data
if [ ! -f ./output/align/${FIL}.align.jsonl ] ; then
  ./gentle.sh $FIL chevron.tpt
fi

# Extract speaker information from the .tpt file
if [ -f ./input/$FIL.tpt ]
then
  grep -o "|Person=.*" ./input/$FIL.tpt > ./input/$FIL.speaker.list
  # Run the converterto locate speaker turns and insert speaker info back
  python align2spk.py -o $HOME/data_tmp/output/spk/$FIL.align.spk -s $HOME/data_tmp/input/$FIL.speaker.list $HOME/data_tmp/output/align/$FIL.align.jsonl
fi

# Extract Audio Clips
python spk_extract.py -o $OUTDIR/ -i $INDIR/ -f $FIL -s $OUTDIR/spk/

# Delete the Files got from Cartago
rm $INDIR/${FIL}*

# Put the results back to Cartago
./put.sh ./output/align/${FIL}.align.jsonl align
./put.sh ./output/spk/${FIL}.align.spk spk


