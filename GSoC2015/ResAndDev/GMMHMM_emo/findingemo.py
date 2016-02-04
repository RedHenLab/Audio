from hmmlearn.hmm import GMMHMM
import scipy.io.wavfile as wvf
from features import mfcc
import os
import pickle
import glob
import heapq

def create_training_set(trng_path, pickles):
	"""
	Description:
		Function that takes in the directory containing training data as raw wavfiles within folders named according to emotion, extracts MFCC feature vectors from them, accepts a configuration for each emotion in terms of number of states for HMM and number of mixtures in the Gaussian Model and then trains a set of GMMHMMs, one for each emotion. All intermediate results are pickled for easier use later.
		This function is invoked only when training = True in predict_emo().
		
	Params:
		* trng_path (mandatory): Path to the training wav files. Each folder in this path must have the name as emotion and must NOT be empty. If a folder in this path is empty, the emotion will not be considered for classification.
		
		* pickles (mandatory): Path to store the generated pickle files in. Please keep these constant for the purpose of reuse.
		
	Return:
		A python dictionary of GMMHMMs that are trained, key values being emotions extracted from folder names.
	"""
	emotions = os.listdir(trng_path)
	trng_data = read_wavs_trng(emotions, trng_path, pickle_path = pickles+'/trng_data.pkl', use_pickle = False)
	GMM_config = obtain_config(emotions, pickle_path = pickles+'/gmm_conf.pkl', use_pickle = False)
	gmms = train_GMMs(emotions, trng_data, GMM_config, pickle_path = pickles+'/gmmhmm.pkl', use_pickle = False)
	return gmms
	
def read_wavs_trng(emotions, trng_path, pickle_path, use_pickle = False):
	"""
		Utility function to read wav files, convert them into MFCC vectors and store in a pickle file
	"""
	trng_data = {}
	if use_pickle and os.path.isfile(pickle_path):
		write_pickle = False
		trng_data = pickle.load(open(pickle_path,"rb"))
	else:
		write_pickle = True
		for emo in emotions:
			mfccs = []
			for wavfile in glob.glob(trng_path+'/'+emo+'/*.wav'):
				rate,sig = wvf.read(wavfile)
				mfcc_feat = mfcc(sig,rate)
				mfccs.append(mfcc_feat)
			trng_data[emo]=mfccs
	if write_pickle:
		pickle.dump(trng_data, open(pickle_path,"wb"))
	return trng_data

def obtain_config(emotions, pickle_path, use_pickle = False):
	"""
		Utility function to take in parameters to train individual GMMHMMs
	"""
	conf = {}
	if not use_pickle:
		for emo in emotions:
			conf[emo]={}
			print '*'*50
			print emo
			print '*'*20
			conf[emo]["n_components"] = int(input("Enter number of components in the GMMHMM: "))
			conf[emo]["n_mix"] = int(input("Enter number of mixtures in the Gaussian Model: "))
		pickle.dump(conf,open(pickle_path,"wb"))
	else:
		conf = pickle.load(open(pickle_path,"rb"))
	return conf

def train_GMMs(emotions, trng_data, GMM_config, pickle_path, use_pickle = False):
	"""
		Utility function to train GMMHMMs based on entered confiuration and training data. Returns a dictionary of trained GMMHMM objects and also pickles them for use without training.
	"""
	emo_machines = {}
	if not use_pickle:
		for emo in emotions:
			emo_machines[emo] = GMMHMM(n_components=GMM_config[emo]["n_components"],n_mix=GMM_config[emo]["n_mix"])
			if trng_data[emo]:
				#print np.shape(trng_data[emo])
				emo_machines[emo].fit(trng_data[emo])
		pickle.dump(emo_machines, open(pickle_path,"wb"))
	else:
		emo_machines = pickle.load(open(pickle_path,"rb"))
	return emo_machines

def test_emo(test_file , gmms):
	"""
		NOTE: Use only after training.
		Test a given file and predict an emotion for it.
	"""
	rate,sig = wvf.read(test_file)
	mfcc_feat = mfcc(sig,rate)
	pred = {}
	for emo in gmms:
		pred[emo] = gmms[emo].score(mfcc_feat)
	return emotions_nbest(pred, 2)

def emotions_nbest(d,n):
	"""
		Utility function to return n best predictions for emotion.
	"""
	return heapq.nlargest(n ,d, key = lambda k: d[k])

def predict_emo(test_file, pickle_path = ".", trng_path = "../training", training = False):
	"""
		Description:
			Based on training or testing mode, takes appropriate path to predict emotions for input wav file.
		
		Params:
			* test_file (mandatory): Wav file for which emotion should be predicted.
			* pickle_path: Default value is same directory as the python file. Path to store pickle files for use later.
			* trng_path: Default is a folder called training in the enclosing directory. Folder containing training data.
			* training: Default is False. if made True, will start the training procedure before testing, else will used previously trained model to test.
			
		Return:
			A list of predicted emotion and next best predicted emotion.
	"""
	if training and trng_path:
		gmms = create_training_set(trng_path, pickle_path)
		predicted = test_emo(test_file, gmms)
	else:
		gmms = pickle.load(open(pickle_path+"/gmmhmm.pkl","rb"))
		predicted = test_emo(test_file, gmms)
	return predicted

def start():
	choice = str(raw_input("Do you want to train? (y/n): "))
	if choice == "y":
		trng_path = str(raw_input("Enter path to training folder: "))
	testfile = str(raw_input("Please enter path to the wavfile (segment) to predict emotion for: "))
	if choice == "y":
		predicted = predict_emo(testfile, trng_path = trng_path, training = True)
	else:
		predicted = predict_emo(testfile)
	print "EMOTION PREDICTED: %s"%predicted[0]
	print "Next Best: %s"%predicted[1]
	
if __name__=="__main__":
	start()
