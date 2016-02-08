#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"

i=0
limitFloat=`ffprobe -i ${1} -show_entries format=duration -v quiet -of csv="p=0"`
printf -v limit "%.0f" "$limitFloat"
mkdir -p ${2}
audioFile=`basename ${1}`
while [ $i -lt $limit ]
do
	from=$i
	to=$(($i+${3}))
	duration=$(($to-$from))
	printf -v from %04d%s $from
	printf -v to %04d%s $to
 `ffmpeg -loglevel panic -i $1 -ss $from -t $duration -acodec copy ${2}/${audioFile%.m4a}_${from}_${to}.m4a`
	i=$(($i+${4}))
done
