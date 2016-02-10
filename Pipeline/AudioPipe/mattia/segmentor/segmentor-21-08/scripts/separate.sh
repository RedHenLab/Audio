#!/bin/bash
i=0
limitFloat=`soxi -D ${1}`
printf -v limit "%.0f" "$limitFloat"
mkdir -p ${2}
audioFile=`basename ${1}`
while [ $i -lt $limit ]
do
	from=$i
	to=$(($i+${3}))
	printf -v from %04d%s $from
	printf -v to %04d%s $to
#`sox $1 ${2}/${audioFile%.mp3}_${from}_${to}.mp3 trim $from ${3}`
	`ffmpeg -i $1 -ss $from -t $((${to}-${from})) -acodec copy ${2}/${audioFile%.mp3}_${from}_${to}.mp3`
	i=$(($i+${4}))
done
