import sys, commands, os


def Diarization(audio, dest_rttm='temp_rttm', init_cluster=20, dest_mfcc='temp_mfcc', dest_cfg='temp_cfg'):
    current_module = sys.modules[__name__]
    audio_dir = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "temp_audio")
    print commands.getstatusoutput("rm -rf "+audio_dir)
    print commands.getstatusoutput("mkdir -p "+dest_mfcc)
    print commands.getstatusoutput("mkdir -p "+dest_cfg)
    print commands.getstatusoutput("mkdir -p "+dest_rttm)
    print commands.getstatusoutput("mkdir -p "+audio_dir)
    

    audio_nm = audio.split("/")[-1].split(".")[0]
    audio_temp = os.path.join(audio_dir,audio_nm+'.wav')
    print "Now start extracting mfcc features"
    print commands.getstatusoutput("ffmpeg -i "+audio+" -vn -f wav -ar 16k "+audio_temp)
    
    mfcc = os.path.join(dest_mfcc, audio_nm+".seg.feat.gauss.htk")
    mfcc_cfg_path = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "config.mfcc")
    print commands.getstatusoutput("HCopy -C "+mfcc_cfg_path+" "+audio_temp+" "+mfcc)
    rttm = os.path.join(dest_rttm, audio_nm+".rttm")
    cfg = os.path.join(dest_cfg, audio_nm+".cfg")
    
    print "Now start preparing configure file"
    f = open(cfg,'w') 
    f.write("[Diarizer]\n")
    f.write("basename = "+audio_nm.split(".")[0]+"\n")
    f.write("mfcc_feats = "+mfcc+"\n")
    f.write("output_cluster = "+rttm+"\n") 
    f.write("gmm_output = IS.gmm\n")
    
    f.write("em_iterations = 25\n")
    f.write("initial_clusters = "+str(init_cluster)+"\n")
    f.write("M_mfcc = 5\n\n")

    f.write("KL_ntop = 3\n")
    f.write("num_seg_iters_init = 2\n")
    f.write("num_seg_iters = 3\n")
    f.write("seg_length = 250\n")
    f.close()
    
    print "Now start clustering"
    cluster_path = os.path.join(os.path.dirname(os.path.abspath(current_module.__file__)), "cluster.py")
    print commands.getstatusoutput("python "+cluster_path+" -c "+cfg)
    print commands.getstatusoutput("rm -rf "+audio_dir)
    return rttm

    



