#!/bin/bash
INFILE=$1
START=$2
STOP=$3
OUTFILE=$4

OFFSET=`php TimeDiff.php "$START" "$STOP"`

echo "Disecting $INFILE starting from $START to $STOP (duration $OFFSET)"
ffmpeg -ss "$START" -t "$OFFSET" -i "$INFILE" "$OUTFILE"
