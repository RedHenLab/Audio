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



def train_model(audio_dir, spk_name, Model):
    spk_dir = os.path.join(audio_dir,spk_name)
    list_fn = os.path.join(spk_dir,"clip_list.txt")
    clip_ls = from_jsonfile(list_fn)
    audio_merge = merge_clips(spk_dir, clip_ls)
    model_fn = os.path.join(spk_dir,spk_name+".model")
    # Training a model based on the merged audio
    Model.enroll_file(spk_name, audio_merge, model=model_fn)
    return Model

def merge_clips(spk_dir, clip_ls):
    # Write the list of clips into a file for merging training data
    temp_fl = os.path.join(spk_dir,"temp.txt")
    count = 0
    with open(temp_fl, "w") as fh:
        for clip in clip_ls:
            if count>100:
                break
            if clip["zscore"] > - 1:
                fh.write("file "+clip["name"]+"\n")
                count+=1
    # Merge all the data into one audio
    audio_merge = os.path.join(spk_dir,"merged.wav")
    commands.getstatusoutput("ffmpeg -f concat -i "+temp_fl.replace(" ", "\ ")+" -c copy -y "+audio_merge)
    os.remove(temp_fl)
    return audio_merge

def from_jsonfile(filename):
    with open(filename) as fh:
        return json.load(fh)


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
        description='Train a recognizer from a list of speakers.')
parser.add_argument(
    '-d', '--data', dest='data_dir', type=str,
    help='directory of audio data')
parser.add_argument(
    '-s', '--spk', dest='spk_fl', type=str,
    help='file that contains a list of speakers')

args = parser.parse_args()

data_dir = args.data_dir
spk_fl = args.spk_fl

#Read in the list
spk_ls = from_jsonfile(spk_fl)
#Create the GMM Model
Recognizer = SR.GMMRec()
#Enroll the speakers one by one
for spk_name in spk_ls:
    print "Training the model now for "+spk_name
    Recognizer = train_model(data_dir, spk_name, Recognizer)
Recognizer.train()



