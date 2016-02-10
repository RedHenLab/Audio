#!/bin/bash
`mkdir -p ${2}/overlap-clips`
i=0
for video in ${1}/*.mp4; do
  filename=${video##*/}
  `MP4Box -single 2 ${video} -out audio-resources-temp/"${filename%.*}.mp2"`
done
for audio in audio-resources-temp/*.mp2; do
  filename=${audio##*/}
  `scripts/separate.sh $audio audio-resources-temp/overlap-clips/ 15 7`
#  echo scripts/separate-10.sh $audio audio-resources-temp/overlap-clips/ 15 7
done
