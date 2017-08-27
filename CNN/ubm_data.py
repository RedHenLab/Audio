import json, os
import argparse
import numpy as np


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



parser = argparse.ArgumentParser(description='Select speakers based on the dataset statistics.')
parser.add_argument(
                    '-s', '--stats', dest='stats_file', type=str,
                    help='relative path to the dataset statistics file')
parser.add_argument(
                    '-o', '--output', dest='out_file', type=str,
                    help='relative path to the output file')
parser.add_argument(
                    '-d', '--data', dest='data_dir', type=str,
                    help='directory of audio data')


args = parser.parse_args()

data_dir = args.data_dir
stat_path = args.stats_file
stat_dict = from_jsonfile(os.path.join(data_dir,stat_path))

data_sample = []
max_count = 2
#Select clips for training UBM
for spk_name in stat_dict:
    spk_dir = os.path.join(data_dir,spk_name)
    list_fn = os.path.join(spk_dir,"clip_list1.txt")
    clip_ls = from_jsonfile(list_fn)
    clip_num = 0
    sample_ls = []
    for clip in clip_ls:
        if clip_num > max_count:
            break
        if get_sec(clip["duration"]) > 5:
            sample = os.path.join(spk_dir,clip["name"])
            sample_ls.append(sample)
            clip_num+=1
    if sample_ls:
        data_sample.append(sample_ls)


out_file = args.out_file
with open(out_file , "w") as fh:
    fh.write(to_json(data_sample, indent=2))
