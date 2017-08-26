import numpy as np
import sys
sys.path.append("../Pipeline/Audio/Pipeline/")
from AudioPipe.features import mfcc # Feature Extraction Module, part of the shared preprocessing
import AudioPipe.speaker.recognition as SR # Speaker Recognition Module
import scipy.io.wavfile as wav 
import commands, os
import json
import argparse
import warnings
from scipy import stats



def outlier_detect(audio_dir, spk_name):
    spk_dir = os.path.join(audio_dir,spk_name)
    list_fn = os.path.join(spk_dir,"clip_list.txt")
    clip_ls = from_jsonfile(list_fn)
    audio_merge = merge_clips(spk_dir, clip_ls)
    # Training a model based on the merged audio
    Model = SR.GMMRec()
    Model.enroll_file(spk_name, audio_merge)
    Model.train()
    # Score each utterance in the training set
    llhd_ls = []
    new_ls = []
    stat_fn = os.path.join(audio_dir,"stats.json")
    if os.path.exists(stat_fn) and os.path.getsize(stat_fn) > 0:
        stat_dict = from_jsonfile(stat_fn)
    else:
        stat_dict = {}
    if spk_name not in stat_dict:
        stat_dict[spk_name]={}
    for clip in clip_ls:
        audio_test = os.path.join(spk_dir,clip["name"])
        #commands.getstatusoutput("ffmpeg -i "+audio_test+" -vn -f wav -ab 16k "+audio_test)
        try:
            llhd = Model.predict(Model.get_mfcc(audio_test))[1]
        except ValueError:
            print clip["name"]
            continue
        llhd_ls.append(llhd)
        clip["llhd"] = llhd
        new_ls.append(clip)
    z_score = stats.zscore(llhd_ls)
    for i in xrange(len(llhd_ls)):
        new_ls[i]["zscore"] = z_score[i]
    with open(list_fn, "w") as fh:
        fh.write(to_json(new_ls, indent=2))
    stat_dict[spk_name]["clip_num"]=len(clip_ls)
    stat_dict[spk_name]["zpos_num"]=sum(z_score>0)
    stat_dict[spk_name]["total_duration"]=sum([get_sec(clp["duration"]) for clp in new_ls])
    stat_dict[spk_name]["clean_duration"]=sum([get_sec(clp["duration"]) for clp in new_ls if clp["zscore"]>-0.00001])
    with open(stat_fn, "w") as fh:
        fh.write(to_json(stat_dict, indent=2))
    os.remove(audio_merge)
    return llhd_ls

def merge_clips(spk_dir, clip_ls):
    # Write the list of clips into a file for merging training data
    temp_fl = os.path.join(spk_dir,"temp.txt")
    count = 0
    with open(temp_fl, "w") as fh:
        for clip in clip_ls:
            if count>100:
                break
            fh.write("file "+clip["name"]+"\n")
            count+=1
    # Merge all the data into one audio
    audio_merge = os.path.join(spk_dir,"merged_gross.wav")
    commands.getstatusoutput("ffmpeg -f concat -i "+temp_fl.replace(" ", "\ ")+" -c copy -y "+audio_merge)
    os.remove(temp_fl)
    return audio_merge

def from_jsonfile(filename):
    with open(filename) as fh:
        return json.load(fh)

def get_sec(time_str):
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + float(s)

def to_json(result, **kwargs):
        '''Return a JSON representation of the aligned transcript'''
        options = {
                'sort_keys':    True,
                'indent':       4,
                'separators':   (',', ': '),
                }
        options.update(kwargs)

        return json.dumps(result, **options)
    

    
parser = argparse.ArgumentParser(
        description='Detect outliers in a training dataset of one speaker.')
parser.add_argument(
    '-i', '--input', dest='input_dir', type=str, 
    help='directory of audio clips')  
parser.add_argument(
    '-s', '--spk', dest='spk_name', type=str, 
    help='the name of the speaker')  

args = parser.parse_args()
    
    
audio_dir = args.input_dir
spk_name = args.spk_name

with warnings.catch_warnings():
    warnings.simplefilter("ignore")
    outlier_detect(audio_dir, spk_name)


