import io
import json
import nltk 
import argparse
import sys
import logging
import re


def from_jsonfile(filename):
    with open(filename) as fh:
        return json.load(fh)
    
def align_tokens(tokens, sentence):    
    point = 0
    offsets = []
    for token in tokens:
        try:
            start = sentence.index(token, point)
        except ValueError:
            raise ValueError('substring "{}" not found in "{}"'.format(token, sentence))
        point = start + len(token)
        offsets.append((start, point))
    return offsets
    
def mark_sent_boun(transcript):
    transcript = transcript.replace("#","%")
    sent_aligned = list(align_tokens(nltk.sent_tokenize(transcript), transcript))
    bound_list = []
    pattern = re.compile("[\W]")
    for offsets in sent_aligned:
        pos = offsets[1]
        if pattern.match(transcript[pos-1:pos]) != None:
            bound_list.append(transcript[pos-1:pos])
            transcript = transcript[0:pos-1]+'#'+transcript[pos:]
    return transcript, bound_list

def to_json(result, **kwargs):
        '''Return a JSON representation of the aligned transcript'''
        options = {
                'sort_keys':    True,
                'indent':       4,
                'separators':   (',', ': '),
                }
        options.update(kwargs)

        return json.dumps(result, **options)

    
def align2spk(transcript, words, bound_list, spk_ls):
    # initialize the head position in audio and text
    head = 0
    head_t = 0
    # create a list for the output
    dict_list = []
    # boolean flag indicating that the timestap is inferred from nearest aligned word
    cautious = False
    bound_itr = 0
    fspk = open(spk_ls, "r")
    for word in words:
        if word['case'] in ('success', 'not-found-in-audio'):
            tail = word['startOffset']
            segment = transcript[head:tail]
            token_list = segment.split()
            for token in token_list:
                tk_dict = {}
                if '>>' in token:
                    #print segment 
                    tk_dict['speaker'] = token.replace(">>", fspk.next())
                    #print tk_dict['speaker']
                elif '#' in token:
                    tk_dict['boundary'] = token.replace("#", bound_list[bound_itr])
                    bound_itr = bound_itr+1
                else:
                    tk_dict['punctuation'] = token
                
                if 'start' in word:
                    tk_dict['end'] = word['start']
                else:
                    tk_dict['end']='NA'  
		    tk_dict['case']='cautious'       
                if cautious:
                    tk_dict['case']='cautious'
                elif 'case' not in tk_dict:
		    tk_dict['case']= 'fine'
                tk_dict['start'] = head_t
                dict_list.append(tk_dict)
            if word['case'] == 'not-found-in-audio':
                word['start'] = head_t
                word['end'] = 'NA'
            dict_list.append(word)
            head = word['endOffset']
            if word['case'] == 'success':
                head_t = word['end']
                cautious = False
            else:
                cautious = True

    segment = transcript[head:]
    token_list = segment.split()
    for token in token_list:
        tk_dict = {}
        if '>>' in token:
            print token
            tk_dict['speaker'] = token.replace(">>", fspk.next())
        elif '#' in token:
            tk_dict['boundary'] = token.replace("#", bound_list[bound_itr])
        else:
            tk_dict['punctuation'] = token
        if cautious:
            tk_dict['case'] = 'cautious'
	else:
 	    tk_dict['case'] = 'fine'
        tk_dict['start'] = head_t
        tk_dict['end'] = 'end-of-audio'
        dict_list.append(tk_dict) 
    #loop through the list in reversed order to fill in the missing end time
    tail_t = 'end-of-audio'
    for tk in reversed(dict_list):
	if 'NA' == tk['end']:
            tk['end'] = tail_t
        if tk['case']== 'success':
  	    tail_t = tk['start']
       
    return dict_list    

        
        
parser = argparse.ArgumentParser(
        description='Using Gentle Alignment result to locate speaker turns.')    
parser.add_argument(
    '-o', '--output', metavar='output', type=str, 
    help='output filename')  
parser.add_argument(
    'jsonfl', type=str,
    help='alignment result in a json file')
parser.add_argument(
    '-s', '--spkls', metavar='spkls', type=str,
    help='speaker list')
args = parser.parse_args()

data = from_jsonfile(args.jsonfl)
transcript = data['transcript']
words = data['words']
transcript_marked, bound_list = mark_sent_boun(transcript)
result = align2spk(transcript_marked, words, bound_list, args.spkls)
fh = open(args.output, 'w') if args.output else sys.stdout
fh.write(to_json(result, indent=2))
log_level = "INFO".upper()
logging.getLogger().setLevel(log_level)
if args.output:
    logging.info("output written to %s" % (args.output))
