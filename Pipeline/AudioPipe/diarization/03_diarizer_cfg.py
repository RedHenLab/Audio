#!/usr/bin/python


import sys,commands
data_dir = sys.argv[1] ## extracted ".wav" folder path
seg_dir = data_dir+"_mfcc" 
cfg_dir = data_dir+"_cfg"
dia_dir = data_dir+"_dia"

networks = commands.getstatusoutput("ls "+data_dir)[1].split()
home_path = "/home/hxx124/Pipeline/Audio/Pipeline/AudioPipe/diarization" # set path to home folder of pycasp

for net in networks :
     net1 = data_dir+"/"+net
     seg_net = seg_dir+"/"+net
     dia_net = dia_dir
     print seg_net
     commands.getstatusoutput("mkdir -p "+dia_net)
     audio_files = commands.getstatusoutput("ls "+net1)[1].split()
     for audio in audio_files:
	  f = open(cfg_dir+"/"+audio.split(".")[0]+".cfg",'w')
          audio1 = net1+"/"+audio
	  
	  f.write("[Diarizer]\n")
	  f.write("basename = "+audio.split(".")[0]+"\n")
          f.write("mfcc_feats = "+home_path+"/"+seg_net+"/"+audio.split(".")[0]+".seg.feat.gauss.htk\n")
          f.write("output_cluster = "+home_path+"/"+dia_net+"/"+audio.split(".")[0]+".rttm\n") 
	  f.write("gmm_output = IS.gmm\n")
    
	  f.write("em_iterations = 25\n")
          f.write("initial_clusters = 200\n")
	  f.write("M_mfcc = 5\n\n")

	  f.write("KL_ntop = 3\n")
	  f.write("num_seg_iters_init = 1\n")
	  f.write("num_seg_iters = 1\n")
	  f.write("seg_length = 250\n")



