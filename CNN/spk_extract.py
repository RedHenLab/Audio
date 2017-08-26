import json
import datetime
import time
import subprocess
import argparse
import os

def to_hhmmss(sec):
    min,sec = divmod(sec,60)
    hr,min = divmod(min,60)
    return "%d:%02d:%06.3f" % (hr,min,sec)

def extract_clip(video, output, start, duration):
    return subprocess.call(['ffmpeg',  "-ss", start, '-i', video, "-write_xing","0", "-t", duration, output])

def from_jsonfile(filename):
    with open(filename) as fh:
        return json.load(fh)
    
def find_between( s, first, last ):
    try:
        start = s.rindex( first ) + len( first )
        end = s.index( last, start )
        return s[start:end]
    except ValueError:
        return ""

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
        description='Extract clips according to speaker turns.')    
parser.add_argument(
    '-o', '--output', dest='output_dir', type=str, 
    help='output directory')  
parser.add_argument(
    '-i', '--input', dest='input_dir', type=str, 
    help='input directory')  
parser.add_argument(
    '-s', '--spk', dest='spk_dir', type=str, 
    help='directory containing the file of speaker turns')  
parser.add_argument(
    '-f', '--filename', dest='fn', type=str,
    help='spk info in a json file')
args = parser.parse_args()
    
    
#output_dir = "../output/"    
#fn = "2006-10-02_1600_US_CNN_Your_World_Today"
fn = args.fn
spkfl = args.spk_dir+fn+".align.spk"
data = from_jsonfile(spkfl)
#input_dir = "../data/"
video = args.input_dir+fn+".mp4"


output_dir = args.output_dir+"audio/"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)
spk_dict= {}
include = False
next_sent = False
head_t = 0
record_dict={}


for tk in data:
    if ("speaker" in tk) and ("fine" in tk["case"]):
        # Get the name when a speaker appears
        spk_name = find_between(tk["speaker"].strip()+"|", "Person=","|")
	spk_name = spk_name.replace(" ", "_" )
    spk_name = spk_name.replace("/", "_" )
        # Set the iterator for this speaker to 0, if appears the first time
        if spk_name not in spk_dict:
            spk_dict[spk_name] = {}
            spk_dict[spk_name]["i"] = 0
            spk_dict[spk_name]["clips"] = []
        spk_dir = output_dir+spk_name
        # Create a directory for this speaker to collect training data if not exist already
        if not os.path.exists(spk_dir):
            os.makedirs(spk_dir)
        # Include the speech that follows
        include = True
        # Set the end time of speaker turn to be start time to include
        head_t = tk["end"]
    elif include and ("boundary" in tk):
        #if "fine" in tk["case"]:
            # When hits the end of a sentence, extract the clip
        tail_t = tk["start"]
        clip_name = fn+"_"+spk_name+str(spk_dict[spk_name]["i"])+".wav"
        start_t=to_hhmmss(head_t)
        duration = to_hhmmss(tail_t - head_t) 
        clip_fn = spk_dir+"/"+clip_name
        extract_clip(video, clip_fn, start_t, duration)
        spk_dict[spk_name]["clips"].append({"name":clip_name, "start":start_t, "duration":duration})
        spk_dict[spk_name]["i"]+=1
        #next_sent = True            
        include = False
        
    #elif next_sent and ("success" in tk["case"]):
        #head_t = tk["start"]
        #next_sent = False
    
      
for spk in spk_dict:
    list_fn = output_dir+spk+"/clip_list.txt"
    clip_ls = []
    if os.path.exists(list_fn):
        clip_ls = from_jsonfile(list_fn)
    diff_ls = [clip_it for clip_it in spk_dict[spk]["clips"] if clip_it not in clip_ls]
    clip_ls = clip_ls + diff_ls
    fh = open(list_fn, 'w')
    fh.write(to_json(clip_ls, indent=2))

