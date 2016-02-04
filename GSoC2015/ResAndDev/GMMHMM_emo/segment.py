''' 
	Runs voiceid (based on LIUM Diarization toolkit) which will create segmented 
	wav files as a by-product
	
	The segmented wav files are categorized into folders (Name does not matter)
	These are used to train the models for emotion recognition

	Ideal Scenario:

	After RedHen's diarization component is ready, we can use that to diarize the 
	audio free from advertisements and then segregate into relevant custers and 
	consequently use those to train models
'''

from voiceid.sr import Voiceid
from voiceid.db import GMMVoiceDB
import sys


def segment_input(wavfile, dbpath='./voicedb'):
	db = GMMVoiceDB(dbpath)
	v = Voiceid(db, wavfile)
	v.extract_speakers()
	
	speaker_clusters={}
	
	for c in v.get_clusters():
		cluster = v.get_cluster(c)
		print cluster
		cluster.print_segments()
		print

if __name__=="__main__":
	if len(sys.argv)<2:
		print "Usage: python segment.py <wavfile_path>"
	else:
	segment_input(sys.argv[1])
	
