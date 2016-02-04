#!/bin/bash

inp=$1 #input wave file
out=$2 #out seg file
showname=`echo "$inp" | cut -d'.' -f1`

LOCALCLASSPATH=/Users/apple/gsoc/NEW/dia/LIUM/lium.jar

java -Xmx2024m -jar "$LOCALCLASSPATH" --fInputMask=$inp --sOutputMask=$out --doCEClustering  $showname
