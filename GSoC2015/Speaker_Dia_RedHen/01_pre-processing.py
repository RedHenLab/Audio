#!/usr/bin/python

'''
Author : Karan Singla

This script helps to does the following

1. Extracts Audio data using ffmpeg in ".wav" from ".mp4"
2. Saves the data in same data folder according to different channels

Features : 

1. Multi-Threading

'''

print "      ########################################################################"
print "      ##                 Data-Preprocessing ToolKit                         ##"
print "      ########################################################################\n"
import sys
import commands
import threading
from os.path import basename



###### Re-oraganizing data according to Networks and extracting Audio from Mp4 Files ######
data_dir = sys.argv[1] #path to data folder
data_org = sys.argv[2] #path to organized and converted data
ls = commands.getstatusoutput("ls "+data_dir)[1].split() #contents of data folder


print "Generate Audio for Data\n"

def audio(name,lower,upper):

    for i in range(lower,upper):
	if ls[i].split(".")[1] == "mp4":
		network = ls[i].split("_")[3]+"/"
		print name+" : Video File: "+ls[i]+" in "+network+"    "
		commands.getstatusoutput("mkdir -p "+data_org+"/"+network)
		commands.getstatusoutput("ffmpeg -i "+data_dir+ls[i]+" -vn -f wav -ab 16k "+data_org+"/"+network+ls[i].split(".")[0]+".wav")
                print "Audio extracted from this file"
try:
		threads = []
		print ls,"THIS IS LENS",len(ls)
		t1 = threading.Thread(target=audio, args=("Thread-1",0,int(len(ls)/4),))
		t2 = threading.Thread(target=audio, args=("Thread-2",int((len(ls)/4)),int((len(ls)/2)),))
		t3 = threading.Thread(target=audio, args=("Thread-3",int((len(ls)/2)),int((len(ls)*3/4)),))
		t4 = threading.Thread(target=audio, args=("Thread-4",int((len(ls)*3/4)),int((len(ls))),))
		threads.extend([t1,t2,t3,t4])
		for x in threads:
			x.start()
		for x in threads:
			x.join()

except:
	print "Error: unable to start thread"

print "Audio Generated\n"

