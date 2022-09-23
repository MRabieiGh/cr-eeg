close all
clear
clc

load(fullfile('..', 'utils', 'eeg128.mat'))

%% Load Data
data_path = 'G:\Data\EEG';
subjects  = ls(fullfile(data_path, 'ft_*.mat'));
isubject  = listdlg('ListString', ...
    replace(string(subjects(:, 4:(end))), '.mat', ''));
load(fullfile(data_path, subjects(isubject, :)))

%%
tmp = subjects(isubject, :);
tmp = replace(tmp, 'ft_', '');
tmp = replace(tmp, '.mat', '');
tmp = replace(tmp, '_', ' ');

tmp = lower(tmp);
idx = regexp([' ' tmp],'(?<=\s+)\S','start')-1;
tmp(idx) = upper(tmp(idx));

subjectName = tmp;
clear tmp

%%
cfg = [];
cfg.lpfilter = 'yes';
cfg.lpfreq   = 32;

data = ft_preprocessing(cfg, data);

%%
cfg = [];
avg = ft_timelockanalysis(cfg, data);

cfg = [];
cfg.xlim = [-0.05, 0.35];
cfg.baseline = [-0.05, 0];
cfg.layout = layout;
figure; ft_multiplotER(cfg, avg);

%%
addpath("G:\Codes\Common")
lbl = grablabels('face-body');
y = find(lbl == 0);

%%
cfg = [];
cfg.trials = ismember(data.trialinfo, y);
dummy = ft_selectdata(cfg, data);
cfg = [];
avgF = ft_timelockanalysis(cfg, dummy);

cfg = [];
cfg.trials = ~ismember(data.trialinfo, y);
dummy = ft_selectdata(cfg, data);
cfg = [];
avgN = ft_timelockanalysis(cfg, dummy);

%%
cfg = []; 
cfg.layout = layout; 
cfg.baseline = [-0.05, 0]; 
cfg.xlim = [-0.05, 0.35];

figure('Position', [0, 0, 1920, 1080])
ft_multiplotER(cfg, avgF, avgN);
suptitle("Subject: " + subjectName)

saveas(gcf, strcat(replace(lower(strtrim(subjectName)), ' ', '-'), '.png'))