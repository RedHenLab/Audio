#!/usr/bin/bash

# tpt file 
tpt=$1
#Corresponding Seg file
seg=$2

echo "Number of speakers in TPT file"
grep ">>" $tpt | grep ":" |cut -d":" -f1 | cut -d"|" -f4 | sort -u | wc

echo "Number of speakers/Cluster-ID's in SEG fil"
grep "test" $seg | cut -d" " -f8 |sort |uniq|wc

