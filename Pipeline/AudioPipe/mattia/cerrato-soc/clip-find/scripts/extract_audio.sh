#!/bin/bash
`mkdir -p ${2}/overlap-clips`
i=0
echo "fetching videos from the sweep folder..."
for video in ${1}/*.mp4; do
  filename=${video##*/}
  `MP4Box -single 2 ${video} -out audio-resources-temp/"${filename%.*}.m4a"`
done
echo "creating audio clips... (this will take a long time)"
for audio in ${2}/*.m4a; do
  filename=${audio##*/}
  `scripts/separate.sh $audio ${2}/overlap-clips/ 15 7`
done
