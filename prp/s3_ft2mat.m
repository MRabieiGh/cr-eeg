close all
clear
clc

data_path = 'G:\Data\EEG';
subjects  = ls(fullfile(data_path, 'ft_*.mat'));
isubject  = listdlg('ListString', ...
    replace(string(subjects(:, 4:(end))), '.mat', ''));
load(fullfile(data_path, subjects(isubject, :)))

tmp = subjects(isubject, :);
tmp = replace(tmp, 'ft_', '');
tmp = replace(tmp, '.mat', '');
tmp = replace(tmp, '_', ' ');

tmp = lower(tmp);
idx = regexp([' ' tmp],'(?<=\s+)\S','start')-1;
tmp(idx) = upper(tmp(idx));

subjectName = strtrim(string(tmp));

info = data.trialinfo;
time = data.time{1};
chnl = data.label;
data = reshape(cell2mat(data.trial), [127, 750, length(data.trial)]);
data = permute(data, [3, 1, 2]);

nanind = isnan(data(:, 1, 1));
data = data(~nanind, :, :);
info = info(~nanind);

nStimuli = length(unique(info));
[nTrial, nChannel, nTime] = size(data);

X = NaN(nStimuli, nChannel, nTime);
for iStimuli = 1:nStimuli
    X(iStimuli, :, :) = mean(data(info==iStimuli, :, :), 1);
end

save(fullfile('G:\Data\EEG', "mat-" + replace(lower(subjectName), ' ', '-') + '.mat'), ...
    'X', 'time')
