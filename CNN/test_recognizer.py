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


def get_sec(time_str):
    h, m, s = time_str.split(':')
    return int(h) * 3600 + int(m) * 60 + float(s)


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
parser.add_argument(
    '-m', '--model', dest='model', type=str,
    help='directory where models are placed')

args = parser.parse_args()
    
    
data_dir = args.data_dir
spk_fl = args.spk_fl
model_dir = args.model

#Read in the list
spk_ls = from_jsonfile(spk_fl)
#Load the Recognizer
Recognizer = SR.GMMRec()
for spk_name in spk_ls:
    spk_dir = os.path.join(model_dir,spk_name)
    model_fn = os.path.join(spk_dir,spk_name+".model")
    Recognizer.enroll_model(spk_name, model_fn)
#Num of clips tested on
num_total = 0
#Num of correctly recognized clips
num_correct = 0
#List to store the testing results
result_ls = []

#Recognize the audios
for spk_name in spk_ls:
    spk_dir = os.path.join(data_dir,spk_name)
    list_fn = os.path.join(spk_dir,"clip_list.txt")
    clip_ls = from_jsonfile(list_fn)
    for clip in clip_ls:
        if clip["zscore"] > -0.1 and get_sec(clip["duration"]) > 3:
            audio_test = os.path.join(spk_dir,clip["name"])
            try:
                id = Recognizer.predict(Recognizer.get_mfcc(audio_test))[0]
                num_total+=1
                if id == spk_name:
                    num_correct+=1
		    print num_correct, num_total
                result_ls.append((clip["name"], id))
            except ValueError:
                print clip["name"]
                continue

    
with open("test_results.json", "w") as fh:
    fh.write(to_json(result_ls, indent=2))

print num_correct, "out of ", num_total, "are correctly recognized!"
