#!/bin/bash
#
# Get files from cartago
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

# Strip any extensions
FIL=${1%%.*}

DIR="/db/tv/${FIL:0:4}/${FIL:0:7}/${FIL:0:10}"
rsync cah:$DIR/$FIL.tpt ./input/ -aP

DIR="/sweep/${FIL:0:4}/${FIL:0:7}/${FIL:0:10}"
rsync cah:$DIR/$FIL.mp4 ./input/ -aP


