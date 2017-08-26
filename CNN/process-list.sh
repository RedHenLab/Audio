#!/bin/bash
#
# Loop through a list of new videos and extract training audio clips from each of them
#
#


# The file that contains the list
LIST=$1

for FFIL in `cat $LIST` ; do
  ./collect-train.sh $FFIL
done
