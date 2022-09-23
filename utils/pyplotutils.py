import os

import numpy as np
import seaborn as sns
from matplotlib import pyplot as plt
from scipy.ndimage import gaussian_filter as smooth


def plotLDA(subject, cm, region, time, sigma=5, fig_path='.'):
    acc = np.diagonal(cm, axis1=2, axis2=3).sum(2) / cm.sum((2, 3)) * 100
    recall = np.diagonal(cm, axis1=2, axis2=3) / cm.sum(3) * 100

    fig, axs = plt.subplots(1, 2, figsize=(14, 4), sharey=False)

    acc = smooth(acc, sigma=sigma)
    axs[0].plot(time, acc.mean(0), lw=3)
    axs[0].fill_between(time,
                     acc.mean(0) - acc.std(0),
                     acc.mean(0) + acc.std(0),
                     alpha=.1, label='_nolegend_')
    axs[0].set_title('Accuracy', fontsize=14)

    for icat in np.arange(4):
        r = smooth(recall[:, :, icat], sigma=sigma, axis=-1)
        axs[1].plot(time, r.mean(0), lw=3)
        axs[1].fill_between(time,
                         r.mean(0) - r.std(0),
                         r.mean(0) + r.std(0),
                         alpha=.1, label='_nolegend_')
    axs[1].set_xlim(-50, 500)    
    axs[1].legend(['Face', 'Body', 'Artificial', 'Natural'], frameon=False)
    axs[1].set_title('Recall', fontsize=14)

    sns.despine()
    for ax in axs:
        ax.tick_params(axis='both', which='major', labelsize=12)
        ax.axvline(0, c='gray', ls='--', label='_nolegend_')
        ax.axhline(25, c='gray', ls='--', label='_nolegend_')
        ax.axvline(170, c='gray', ls='--', label='_nolegend_')
        ax.set_xlim(-50, 500)
        # ax.set_ylim(0, 100)
    
    fig.suptitle(f"LDA Performance on Subject: {subject.replace('-', ' ').capitalize().title()} - {region.capitalize()}", fontsize=20)
    fig.tight_layout()
    plt.savefig(os.path.join(fig_path, subject, f'lda-{region}.jpg'), dpi=600)
