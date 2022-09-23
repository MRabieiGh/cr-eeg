import os
import numpy as np

def print_prompt(subjects):
    os.system('cls')
    print("Select one of the subjects by entering the corresponding name")
    print("[0]: Iterate over all the subjects")
    for iterator, name in enumerate(subjects):
        print(f"[{iterator + 1}]: {name.replace('-', ' ').title()}")

def print_region(regions):
    print("Select one of the regions")
    print("[0]: Brainwide")
    for iterator, name in enumerate(regions):
        print(f"[{iterator + 1}]: {name}")
    # print(f"[{iterator + 2}]: Iterate over all regions")

def select_subject(subjects):
    index = -1
    while (index < 0):
        print_prompt(subjects)
        index = input('Index: ')
        if index.isnumeric() and (int(index) in np.arange(0, len(subjects)+1)):
            index = int(index)
            break
        index = -1
    
    if index == 0: # all subjects
        return np.arange(len(subjects))
    else:
        return np.array([index-1])

def select_region(channelRegions):
    regions = np.unique(channelRegions)

    index = -1
    while (index < 0):
        print_region(regions)
        index = input('Index: ')
        if index.isnumeric() & (int(index) in np.arange(0, len(regions) + 2)):
            index = int(index)
            break
        index = -1
            
    if index == 0:
        return (np.arange(len(channelRegions)), 'Brainwide')
    else:
        return (np.argwhere((channelRegions == regions[index - 1]).to_numpy()).flatten(), regions[index - 1])