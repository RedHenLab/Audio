#!/bin/bash


# The single-show output diarization need to be merge in one diarization file. The ID of each speaker must be dependent of the show. For example use the script below to make unique the speaker ID.

net=$1
net_cross=$2

cat $net/* | grep "^[^;;]" | perl -e '
       $i=0;
       while(<>){
             chomp; 
             @t=split(/ +/); 
             $n=$t[0]." ".$t[7]; 
        
             if(! exists($d{$n})) { 
                     $d{$n}="S".$i;
                     $i++;
             }
             print "$t[0] $t[1] $t[2] $t[3] $t[4] $t[5] $t[6] ".$d{$n}."\n";
       }'> $2



