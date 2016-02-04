#!/usr/bin/python


import sys,commands
data_dir = sys.argv[1]
seg_dir = data_dir+"_seg"

networks = commands.getstatusoutput("ls "+data_dir)[1].split()

for net in networks :
     net1 = data_dir+"/"+net
     seg_net = seg_dir+"/"+net
     print seg_net
     commands.getstatusoutput("mkdir -p "+seg_net)
     audio_files = commands.getstatusoutput("ls "+net1)[1].split()
     for audio in audio_files:
          audio1 = net1+"/"+audio
	  seg =  seg_net+"/"+audio.split(".")[0]

	  print "Diarizing "+audio1+" file in "+net+" Network"
          print commands.getstatusoutput("sh scripts/diarization.sh "+audio1+" "+seg)
          print "File Diarized"



