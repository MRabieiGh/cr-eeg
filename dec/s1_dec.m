close all
clear
clc

load(fullfile('..', 'eeg128.mat'))
addpath('G:\Codes\cr-eeg\utils')

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

subjectName = string(tmp);
clear tmp idx

%%
d = data;

%% Secondary Preprocessing
cfg                 = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 32;
cfg.baselinewindow  = [-.2 0];

data = ft_preprocessing(cfg, data);

%% Grab the Data from Fieldtrip
info = data.trialinfo;
time = data.time{1};
chnl = data.label;
data = reshape(cell2mat(data.trial), [127, 750, length(d.trial)]);
data = permute(data, [3, 1, 2]);

%%
nanind = isnan(data(:, 1, 1));
data = data(~nanind, :, :);
info = info(~nanind);

%%
nStimuli = length(unique(info));
[nTrial, nChannel, nTime] = size(data);

X = NaN(nStimuli, nChannel, nTime);
for iStimuli = 1:nStimuli
    X(iStimuli, :, :) = mean(data(info==iStimuli, :, :), 1);
end

%%
addpath("G:\Codes\Common")
lbl = grablabels('face-body'); lbl = lbl(1:155);
fac = find(lbl == 0);
bod = find(lbl == 1);
lbl = grablabels('super-ordinate'); lbl = lbl(1:155);
ani = find(lbl == 0);
ina = find(lbl == 1);

%% Category Event-Related Potentials per each Channel
mkdir(replace(lower(subjectName), ' ', '-'))
for iFigure = 1:14
    figure('Position', [0 0 1920 1080])
    ax = [];
    for iChannel = (iFigure-1)*9 + (1:9)
        ax = [ax, nexttile];
        options = {'LineWidth', 5};
        plot(time, mean(squeeze(X(fac, iChannel, :))), options{:})
        hold on
        plot(time, mean(squeeze(X(bod, iChannel, :))), options{:})
        plot(time, mean(squeeze(X(ani, iChannel, :))), options{:})
        plot(time, mean(squeeze(X(ina, iChannel, :))), options{:})
        xline(0, 'Color', [.5 .5 .5 .5], 'LineStyle', '--', 'LineWidth', 3)
        xlim([-.2, .5])
        title(chnl(iChannel))
        touch(gca)
    end
    saveas(gcf, fullfile(replace(strtrim(lower(subjectName)), ' ', '-'), ...
        "fig" + num2str(iFigure) + '.png'))
    close gcf
end

%%
lbl = grablabels('face-body'); lbl = lbl(1:155);
fac = find(lbl == 0);
bod = find(lbl == 1);
lbl = grablabels('artificial-natural'); lbl = lbl(1:155);
art = find(lbl == 0);
nat = find(lbl == 1);

categories = NaN(1, nStimuli);
categories(fac) = 0;
categories(bod) = 1;
categories(art) = 2;
categories(nat) = 3;
bad_stim = isnan(categories);

categories(bad_stim) = [];
X(bad_stim, :, :) = [];
y = categories;

save(fullfile('G:\Data\EEG', "xp-" + replace(strtrim(lower(subjectName)), ' ', '-') + '.mat'), ...
    'X', 'y', 'time')
