#!/bin/bash
#
# Put completed files on cartago
#
# -------------------------------------------------

FIL=$1

SUBDIR=$2

FN=${FIL##*/}

DIR="~/output/$SUBDIR/${FN:0:4}/${FN:0:7}/${FN:0:10}"
ssh cah "mkdir -p $DIR"
rsync $FIL cah:$DIR/$FN -aP


