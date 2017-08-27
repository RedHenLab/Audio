import json
import argparse
import numpy as np


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

def qualify(spk_name, spk_dict):
    meet_criteria = (spk_dict["clean_duration"] > 60) and \
                    (spk_dict["zpos_num"] > 10) and \
                    (not spk_name.isupper())
    
    return meet_criteria


parser = argparse.ArgumentParser(description='Select speakers based on the dataset statistics.')
parser.add_argument(
                    '-s', '--stats', dest='stats_file', type=str,
                    help='relative path to the dataset statistics file')
parser.add_argument(
                    '-o', '--output', dest='out_file', type=str,
                    help='relative path to the output file')

args = parser.parse_args()

stat_path = args.stats_file
stat_dict = from_jsonfile(stat_path)

spk_ls = [spk for spk in stat_dict if qualify(spk, stat_dict[spk])]

speaker_list = args.out_file
with open(speaker_list , "w") as fh:
    fh.write(to_json(spk_ls, indent=2))
