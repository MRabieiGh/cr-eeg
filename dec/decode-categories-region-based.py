import json
import os
import pickle
import sys
from glob import glob

with open('../utils/dirs.json', 'r') as f:
    dirs = json.load(f)
sys.path.append(dirs['root'])

import numpy as np
import pandas as pd
import seaborn as sns
from imblearn.under_sampling import RandomUnderSampler as rus
from matplotlib import pyplot as plt
from scipy.io import loadmat
from scipy.ndimage import gaussian_filter1d as smooth
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import StratifiedKFold
from tqdm import tqdm

from utils.prompts import select_region, select_subject
from utils.pyplotutils import plotLDA

data_path = dirs['data']
out_path  = dirs['out']['dec']

subjects = []
for subject in glob(os.path.join(data_path, 'mat-*.mat')):
    name = '-'.join(os.path.basename(subject).split('.')[0].split('-')[1:3])
    subjects.append(name)

with open(os.path.join('/Codes/eeg-categorical-representation/utils', 'channels.pkl'), 'rb') as fp:
    chInfo = pickle.load(fp)      

with open(os.path.join('/Codes/eeg-categorical-representation/utils', 'info.pkl'), 'rb') as fp:
    info = pickle.load(fp)

subjectIndices = select_subject(subjects)
channelIndices, region = select_region(chInfo['reg'])

for index in subjectIndices:
    subject = subjects[index]
    os.makedirs(os.path.join(out_path, subject), exist_ok=True)

    d = loadmat(os.path.join(data_path, f'mat-{subject}.mat'))
    categories = info.cat.to_numpy()[:155]

    labels = categories[categories != 'none']
    data = d['X'][categories != 'none'][:, channelIndices, :]
    
    confusionMatrices = []
    for repetition in tqdm(range(50)):
        trial_index, _ = rus().fit_resample(np.arange(len(labels)).reshape(-1, 1), labels.reshape(-1, 1))
        X, y = data[trial_index.flatten()], labels[trial_index.flatten()]
        
        kfold = StratifiedKFold(n_splits=5, shuffle=True, random_state=repetition)
        cm = []

        for train_index, test_index in kfold.split(X=y, y=y):
            X_train, X_test = X[train_index], X[test_index]
            y_train, y_test = y[train_index], y[test_index]

            rep = []

            nSamples = 5
            for w0 in np.arange(0, X_train.shape[2] - nSamples):
                mdl = LinearDiscriminantAnalysis().fit(X_train[:,:,w0:w0+nSamples].mean(2), y_train)
                rep.append(confusion_matrix(y_test, mdl.predict(X_test[:, :, w0:w0+nSamples].mean(2)), labels=['face', 'body', 'artificial', 'natural']))
            cm.append(np.array(rep))
        confusionMatrices.append(np.array(cm))
    confusionMatrices = np.array(confusionMatrices)
    np.save(os.path.join(out_path, subject, f'confusion-matrix-{region}.npy'), confusionMatrices)