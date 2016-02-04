#!/usr/bin/python

''' This scripts converts tpt file format to RTTM format so that it can be converted by NIST evaluation script '''

import os,commands,sys

inp = open(sys.argv[1],'r') # inpit tpt file


FLAG = 0 # initiation mark
UMF = 0  # UNIDENTIFIED Male/Female
def remove_zeros(string): # extracts time stamp for tpt line      
   for i in range(0,len(string)):
       if string[i] != "0":
            return string[i:]
            break

def minutes_seconds(string): # converts 1330 which actually means 13:30 minutes to seconds
   temp = string.split(".")[0][-2:]

   if len(string.split(".")[0]) > 2:
        min2sec = int(string.split(".")[0][:-2])*60
        ans = str(int(temp)+int(min2sec))+"."+string.split(".")[1]
   else:
       ans = str(int(temp))+"."+string.split(".")[1]
   return ans

for line in inp:  ## start of the main loop
      if line[0]=='2':
            temp = line.split("|")
            if temp[2] == "NER_01":
                     xx = temp[3]
                     FLAG = 1
            if FLAG == 1:
                     temp[0] = temp[0][8:]
                     temp[1] = temp[1][8:]
                     temp[0] = minutes_seconds(remove_zeros(temp[0]))
                     temp[1] = minutes_seconds(remove_zeros(temp[1]))
                     if temp[2] == "NER_01": # marks change of speaker turn and who is speaking
                            xx = temp[3]
                            temp[3] = temp[3].split("=")[1]
                            temp[0] = minutes_seconds(remove_zeros(temp[0]))
                            temp[1] = minutes_seconds(remove_zeros(temp[1]))

                            if temp[3].split()[0] == "UNIDENTIFIED":
                                 UMF = UMF + 1
                                 SPK = "UMF"+str(UMF)
#                                 print remove_zeros(temp[0]),remove_zeros(temp[1]),"UMF"+str(UMF)
                            else:
                                 SPK = temp[3].replace(" ","_")
#                                print remove_zeros(temp[0]),remove_zeros(temp[1]),temp[3].replace(" ","_")
                     else:
                             print temp[0],temp[1],SPK
