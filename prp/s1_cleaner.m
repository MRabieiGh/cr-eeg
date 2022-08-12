% Concatenate Consequtive Files
close all
clear
clc

path = uigetdir();

files = string(ls(fullfile(path, '*_00*.mat')));
nfile = length(files);

data = [];
for ifile = 1:nfile
    d = load(fullfile(path, files(ifile)));
    d = squeeze(d.data);
    
    data = [data, d]; %#ok<AGROW>
end

trig = data(130, :);
data = data(2:129, :);
data([63, 64], :) = [];

load(fullfile(path, ls(fullfile(path, '*TaskData.mat'))), 'trials')

FIX_START   = 220;
FIX_BREAK   = 221;
STM_OFFSET  = 222;
TRL_SUCCESS = 223;
TRL_FAILURE = 224;
SESSION_START = 225;

fs = 1200;
redges = [0, diff(trig)];
redges(redges < 0) = 0;

events = find((redges < 200) & (redges > 0));
nevent = length(events);

onsets = [];
for ievent = 1:nevent
    timew = events(ievent):(events(ievent) + 1300 * fs / 1000);
    if (timew(end) > size(data, 2)), continue, end
    trigw = redges(timew);
    trigw = trigw(trigw > 0);
    if ismember(TRL_SUCCESS, trigw)
        onsets = [onsets, events(ievent)];
    end
end

% assert(sum(~isnan([trials.onset])) == length(onsets))
nonset = length(onsets);

save(fullfile(path, 'data.mat'), 'data', '-v7.3')

events = [onsets; redges(onsets)]';
save(fullfile(path, 'events.mat'), 'events')
