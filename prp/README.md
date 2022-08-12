# Inital Data Preprocessing
## Data Concatenation
`s1_concatenator.m ` loads the data parts and concatenates them. It also separates redundant channels and trigger channel and saves two separate files in the session directory:
* `data.mat `: which contains a *126 x n* matrix, corresponding to each of the data channels
* `events.mat`: which includes the digital triggers sent to DAQ from the paradigm system. Redundant triggers such as stimulus offset, trial success and etc. are omitted and only the stimulus onset triggers kept.

# Data Preprocessing
We use the `fieldtrip` toolbox for our initial preprocessing phase. The preprocessing steps entails:
## DownSample
Downsample to 500Hz
## HighPass Filtering
Highpass filter, 1Hz
## Channel Interpolation (If Necessary)
* detection method: visual inspection
* proximity method: `triangulation` 
* interpolation: `spherial spline`
## Re-reference Data to Average Channel
* added zero-filled channel named `LM`, which corresponds to left mastoid, the original reference used in the data acquisition process
## Notch Filtering
* removes the line noise from the data
* band-stop filter between 49 to 51Hz
## ICA Training
* method: `runica`
## LowPass Filtering
