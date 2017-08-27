import operator
import numpy as np
from sklearn.mixture import GMM

class GMMSet(object):

    def __init__(self, gmm_order = 64):
        self.gmms = []
        self.gmm_order = gmm_order
        self.y = []

    def fit_new(self, x, label, gmm_order):
        self.y.append(label)
        if gmm_order=None:
            gmm = GMM(self.gmm_order)
        else:
            gmm = GMM(gmm_order)
        gmm.fit(x)
        self.gmms.append(gmm)
        return gmm
    
    def add_new(self, gmm, label):
        self.y.append(label)
        self.gmms.append(gmm)

    def gmm_score(self, gmm, x):
        return np.sum(gmm.score(x))

    def predict_one(self, x):
        scores = [self.gmm_score(gmm, x) / len(x) for gmm in self.gmms]
        p = sorted(enumerate(scores), key=operator.itemgetter(1), reverse=True)
        result = [(self.y[index], value) for (index, value) in enumerate(scores)]
        p = max(result, key=operator.itemgetter(1))
        return p
