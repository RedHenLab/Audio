import numpy as np
import cPickle as pickle
from AudioPipe.features import mfcc
from silence import remove_silence
import scipy.io.wavfile as wav

#try:
#    from pycaspgmm import GMMSet, GMM
#except:
#    from skgmm import GMMSet, GMM
from skgmm import GMMSet, GMM
class GMMRec(object):

    def __init__(self):
        self.features = []
        self.gmmset = GMMSet()
        self.classes = []
        
    def enroll(self, name, mfcc_vecs):
        mu = np.mean(mfcc_vecs, axis = 0)
        sigma = np.std(mfcc_vecs, axis = 0)
        feature = (mfcc_vecs - mu) / sigma
        feature = feature.astype(np.float32)
        self.features.append(feature)
        self.classes.append(name)
        
    def get_mfcc(self, audio_path):    
        (sr, sig) = wav.read(audio_path)
        if len(sig.shape) > 1:
            sig = sig[:, 0]    
        cleansig = remove_silence(sr, sig)
        mfcc_vecs = mfcc(cleansig, sr, numcep = 15)
        return mfcc_vecs

    def enroll_file(self, name, fn):
        fn_mfcc = np.array(self.get_mfcc(fn)) 
        self.enroll(name, fn_mfcc)
        
    def _get_gmm_set(self):
        return GMMSet()

    def train(self):
        self.gmmset = self._get_gmm_set()
        for name, feats in zip(self.classes, self.features):
            self.gmmset.fit_new(feats, name)
            
    def predict(self, mfcc_vecs):
        mu = np.mean(mfcc_vecs, axis = 0)
        sigma = np.std(mfcc_vecs, axis = 0)
        feature = (mfcc_vecs - mu) / sigma
        feature = feature.astype(np.float32)
        return self.gmmset.predict_one(feature)
            
    def dump(self, fname, part = None):
        with open(fname, 'w') as f:
            if part is None:
                pickle.dump(self, f, -1)
            else:
                pickle.dump(part, f, -1)
                

    @staticmethod
    def load(fname):
        with open(fname, 'r') as f:
            R = pickle.load(f)
            return R
        

            
