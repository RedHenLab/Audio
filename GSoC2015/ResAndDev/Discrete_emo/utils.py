import scipy.io.wavfile as wvf
import scipy.cluster.vq as sp
import numpy as np
import os
import re
import sys
from features import mfcc

def kmeans_Mfcc_mod_train(all_data_file, codebook_size=16 ,wavfiles):
	"""
	Obtain the MFCC coefficients from a wav file as a numpy matrix, then cluster the
	attributes into a single numeric value and write into a file given by opfile
	"""
	rate,sig = wvf.read(all_data_file)
	mfcc_feat = mfcc(sig,rate)
	codebook = sp.kmeans(mfcc_feat, codebook_size)[0]
	#wavfiles = ["new_obama_trng.wav","other_trng.wav"]
	for wavfile in wavfiles:
		final = []
		rate,sig = wvf.read(wavfile)
		mfcc_feat = mfcc(sig,rate)
		data = sp.vq(mfcc_feat,codebook)
		for i in data[0]:
			final.append(i)
		f = open(wavfile.split(".")[0]+"_vq.txt","w")
		for i in final:
			f.write(str(i)+"\n")
		f.close()
	return codebook
	
def read_file(name):
	"""
	Function to take in a training or test file and compose a list of 10-member
	sequences for use later
	"""
	with open(name) as f:
		model=f.readlines()

	s=[]
	sequences=[]
	i=0;

	for word in model:
		i+=1
		word=word[:-1]
		s.append(word)
		if i %10 == 0 or i == (len(model)-1):
			sequences.append(s)
			s=[]

	return sequences

if __name__=="__main__":
	codebook = kmeans_Mfcc_mod_train()	#codebook needed for test data
