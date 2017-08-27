import numpy as np
import cPickle as pickle
from AudioPipe.features import mfcc
from silence import remove_silence
import scipy.io.wavfile as wav
import librosa


from skgmm import GMMSet, GMM
class GMMRec(object):

    def __init__(self):
        self.features = []
        self.gmmset = GMMSet()
        self.classes = []
        self.models = []
    
    def delete_speaker(self, name):
        if name in self.classes:
            ind = self.classes.index(name)
            del self.classes[ind]
            del self.models[ind]
            self.classes.remove(name)
            ind = self.gmmset.y.index(name)
            del self.gmmset.gmms[ind]
            self.gmmset.y.remove(name)
        else:
            print name, "not in the list!"
    
    def enroll_model(self, name, model):
        if name not in self.classes:
            self.classes.append(name)
            self.models.append(model)
            self.features.append(None)
            gmm = self.load(model)
            self.gmmset.add_new(gmm, name)

    def enroll(self, name, mfcc_vecs, model=None):
        if name not in self.classes:
            feature = mfcc_vecs.astype(np.float32)
            self.features.append(feature)
            self.classes.append(name)
            self.models.append(model)
        else:
            print name+" already enrolled, please delete the old one first!"
        
    def get_mfcc(self, audio_path):    
        (sr, sig) = wav.read(audio_path)
        if len(sig.shape) > 1:
            sig = sig[:, 0]    
        cleansig = remove_silence(sr, sig)
        mfcc_vecs = mfcc(cleansig, sr, numcep = 19)
        mfcc_delta = librosa.feature.delta(mfcc_vecs.T)
        mfcc_delta2 = librosa.feature.delta(mfcc_vecs.T, order=2)
        feats=np.vstack([mfcc_vecs.T, mfcc_delta, mfcc_delta2])
        return feats.T

    def enroll_file(self, name, fn, model=None):
        if name not in self.classes:
            fn_mfcc = np.array(self.get_mfcc(fn)) 
            self.enroll(name, fn_mfcc, model=model)
        else:
            print name+" already enrolled, please delete the old one first!"
        
    def _get_gmm_set(self):
        return GMMSet()

    def train(self, gmm_order=None):
        for name, feats, model in zip(self.classes, self.features, self.models):
            if (name not in self.gmmset.y) and (name is not None) :
                gmm = self.gmmset.fit_new(feats, name, gmm_order)
                if model is not None:
                    self.dump(model, part=gmm)
            else:
                print name+" already trained, skip!"
            
    def predict(self, mfcc_vecs):
        feature = mfcc_vecs.astype(np.float32)
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
        

            
