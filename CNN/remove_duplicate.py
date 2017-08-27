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
                    help='dataset statistics file name')
parser.add_argument(
                    '-d', '--data', dest='data_dir', type=str,
                    help='directory of audio data')


args = parser.parse_args()

data_dir = args.data_dir
stat_path = args.stats_file
stat_dict = from_jsonfile(os.path.join(data_dir,stat_path))

for spk_name in stat_dict:
    spk_dir = os.path.join(data_dir,spk_name)
    list_fn = os.path.join(spk_dir,"clip_list.txt")
    clip_ls = from_jsonfile(list_fn)
    new_clip_ls = []
    for clip in clip_ls:
        if clip not in new_clip_ls:
            new_clip_ls.append(clip)
    with open(list_fn, "w") as fh:
        fh.write(to_json(new_clip_ls, indent=2))

