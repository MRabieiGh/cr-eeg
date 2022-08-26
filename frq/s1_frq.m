close all
clear
clc

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
clear tmp idx

%%
cfg = [];
cfg.time = [0, 0.5];
d = ft_selectdata(cfg, data);

cfg              = [];
cfg.output       = 'fourier';
cfg.channel      = 'all';                                                   %compute the power spectrum in all ICs
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 8:2:32;
freq = ft_freqanalysis(cfg, d);

%%
cfg = [];
cfg.method = 'plv';
plv = ft_connectivityanalysis(cfg, freq);

%%
load(fullfile('..', 'utils', 'lobes128.mat'))
lobes = string(lobes);
[sortedLobes, sortInd] = sort(lobes);

%%
figure('Position', [0, 0, 1000, 1000])
tks = 1:126;
p = mean(squeeze(plv.plvspctrm(sortInd, sortInd, plv.freq <= 14)), 3);
p(eye(size(p))==1) = NaN;
imagesc(p)
xticks(tks(1:5:end))
xticklabels(sortedLobes(tks(1:5:end)))
yticks(tks(1:5:end))
yticklabels(sortedLobes(tks(1:5:end)))
% colormap jet
axis image
colorbar
title("Phase Locking Value between Channels of " + strtrim(subjectName))
subtitle(" Frequencies: \alpha")
saveas(gcf, replace(lower(strtrim(subjectName)), " ", "-") + "-alpha.jpg")
close gcf

%%
figure('Position', [0, 0, 1000, 1000])
tks = 1:126;
p = mean(squeeze(plv.plvspctrm(sortInd, sortInd, plv.freq > 14)), 3);
p(eye(size(p))==1) = NaN;
imagesc(p)
xticks(tks(1:5:end))
xticklabels(sortedLobes(tks(1:5:end)))
yticks(tks(1:5:end))
yticklabels(sortedLobes(tks(1:5:end)))
% colormap jet
axis image
colorbar
title("Phase Locking Value between Channels of " + strtrim(subjectName))
subtitle(" Frequencies: \beta")
saveas(gcf, replace(lower(strtrim(subjectName)), " ", "-") + "-beta.jpg")
close gcf

%%
chnames = locations(:, 5);
% split(strtrim(chnames), ' ')
% extract(replace(strtrim(chnames), ' ', )

%%
% cfg.lpfilter = 'yes';
% cfg.lpfreq   = 120;

cfg = [];
cfg.trl = getevents(fullfile(path, 'events.mat'));
tmp = ft_redefinetrial(cfg, components);
tmp.trialinfo = getevents(fullfile(path, 'events.mat'), 'trialinfo');

%%
% cfg = [];
% cfg.trl = getevents(fullfile(path, 'events.mat'));
% data = ft_redefinetrial(cfg, data);
% data.trialinfo = getevents(fullfile(path, 'events.mat'), 'trialinfo');
% 
% %%
% % cfg          = [];
% % cfg.method   = 'trial';
% % dummy        = ft_rejectvisual(cfg, data);
% 
% %%
% cfg          = [];
% cfg.method   = 'summary';
% data_ar      = ft_rejectvisual(cfg, data);
% 
% %%
% cfg          = [];
% cfg.method   = 'trial';
% data_arr     = ft_rejectvisual(cfg, data_ar);
% 
% %%
% cfg = [];
% artf = ft_databrowser(cfg, data_ar)
% 
% %%
% cfg = [];
% avg = ft_timelockanalysis(cfg, data_ar);
% 
% cfg = [];
% cfg.xlim = [-0.05, 0.35];
% cfg.baseline = [-0.05, 0];
% cfg.layout = layout;
% cfg.channel = [1, 3:126];
% figure; ft_multiplotER(cfg, avg);
% 
% %%
% addpath("G:\Codes\Common")
% lbl = grablabels('face-body');
% y = find(lbl == 0);
