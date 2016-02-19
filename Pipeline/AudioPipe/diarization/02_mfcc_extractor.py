#!/usr/bin/python


import sys,commands
data_dir = sys.argv[1] ## extracted ".wav" folder path
seg_dir = data_dir+"_mfcc" 

networks = commands.getstatusoutput("ls "+data_dir)[1].split()

for net in networks :
     net1 = data_dir+"/"+net
     seg_net = seg_dir+"/"+net
     print seg_net
     commands.getstatusoutput("mkdir -p "+seg_net)
     audio_files = commands.getstatusoutput("ls "+net1)[1].split()
     for audio in audio_files:
          audio1 = net1+"/"+audio
	  mfcc =  seg_net+"/"+audio.split(".")[0]+".seg.feat.gauss.htk"
	  print "extracting MFCC features from  "+audio1+" file in "+net+" Network"
	  print commands.getstatusoutput("./tools/htk/bin/HCopy -C ./tools/htk/config.mfcc "+audio1+" "+mfcc)
	  print "Features Extacted"
