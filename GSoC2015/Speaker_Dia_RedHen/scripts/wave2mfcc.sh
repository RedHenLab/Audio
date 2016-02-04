#!/bin/bash                                                                                                                                   

sph=$1                                                                                                                                        
mfcc=$2                                                                                                                                       
tools/spro-4.0/sfbcep -v -F PCM16 -p 12 -m -e -f 16000 $sph $mfcc.tmp
tools/spro-4.0/binary/bin/scopy -B $mfcc.tmp $mfcc
rm $mfcc.tmp
