%% Load the Raw Data
close all
clear
clc

path = uigetdir("G:\Data\EEG\Raw");
load(fullfile(path, 'data.mat'))

d = data;
clear data

load eeg128.mat

%% Convert mat data to fieldtrip-acceptable struct
clc
data.label = layout.label(1:end-2);
data.elec  = layout.cfg.elec;
data.fsample = 1200;
data.trial = {d};
data.time = {(1:size(d, 2)) / data.fsample};

%% Downsample to 500 Hz
cfg = [];
cfg.resamplefs      = 500;
cfg.detrend         = 'no';
data = ft_resampledata(cfg, data);

%% Highpass Filtering for ICA
cfg = [];

cfg.hpfilter = 'yes';
cfg.hpfreq   = 1;

data = ft_preprocessing(cfg, data);

%% Channel Interpolation, If Necessary
if ~isfile(fullfile(path, 'bad_channels.csv'))
    cfg  = [];
    artf = ft_databrowser(cfg, data);
    [index, tf] = listdlg('ListString', layout.label(1:end-2));

    cfg         = [];
    cfg.method  = 'triangulation';
    cfg.channel = data.label;
    cfg.elec    = data.elec;
    neighbours  = ft_prepare_neighbours(cfg, data);

    bad_channels = data.label(index);
    writecell(bad_channels, fullfile(path, 'bad_channels.csv'))
else
    bad_channels = readcell(fullfile(path, 'bad_channels.csv'));
end

if ~isempty(bad_channels)
    cfg            = [];
    cfg.method     = 'spline';
    cfg.badchannel = bad_channels;
    cfg.neighbours = neighbours;
    data           = ft_channelrepair(cfg, data);
end

clear index artf
%% Re-referencing the Data prior to ICA
cfg             = [];
cfg.reref       = 'yes';
cfg.refmethod   = 'avg';
cfg.refchannel  = 'all';
cfg.implicitref = 'LM';
data = ft_preprocessing(cfg, data);

%%
cfg = [];
cfg.bsfilter = 'yes';
cfg.bsfreq   = [49, 51];

data = ft_preprocessing(cfg, data);

%% ICA Training
cfg            = [];
cfg.method     = 'runica';
cfg.runica.pca = 126 - length(bad_channels); % If there are interpolated channels, 126 - NumInterpol
components     = ft_componentanalysis(cfg, data);
save(fullfile(path, 'components.mat'), 'components')










%% Component Rejection
cfg          = [];
cfg.channel  = 1:20; % components to be plotted
cfg.viewmode = 'component';
cfg.layout   = layout; % specify the layout file that should be used for plotting
cfg.component = 1:20;
ft_databrowser(cfg, components);
% ft_topoplotIC(cfg, components)
% ft_icabrowser(cfg, components)


%%

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';%compute the power spectrum in all ICs
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 1:40;
freq = ft_freqanalysis(cfg, components);

%%
figure
plot(freq.freq, pow2db(freq.powspctrm([1, 5], :)))
% ylim([-60, 60])

%%
figure
for i = 1:20
    nexttile
    plot(freq.freq, pow2db(freq.powspctrm(i, :)))
end

%%
% Reject Bad Components
cfg           = [];
cfg.component = [1 5];
data_I1_clean = ft_rejectcomponent(cfg, comp_I1, data_I1);

%%
% cfg.lpfilter = 'yes';
% cfg.lpfreq   = 120;

cfg = [];
cfg.trl = getevents(fullfile(path, 'events.mat'));
tmp = ft_redefinetrial(cfg, components);
tmp.trialinfo = getevents(fullfile(path, 'events.mat'), 'trialinfo');

%%
cfg          = [];
cfg.channel  = 1:20; % components to be plotted
cfg.viewmode = 'component';
cfg.layout   = layout; % specify the layout file that should be used for plotting
cfg.component = 1:20;
ft_databrowser(cfg, tmp);

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
% 
% %%
% cfg = [];
% cfg.trials = ismember(data_ar.trialinfo, y);
% dummy = ft_selectdata(cfg, data_ar);
% cfg = [];
% avgF = ft_timelockanalysis(cfg, dummy);
% 
% cfg = [];
% cfg.trials = ~ismember(data_ar.trialinfo, y);
% dummy = ft_selectdata(cfg, data_ar);
% cfg = [];
% avgN = ft_timelockanalysis(cfg, dummy);
% 
% cfg = []; cfg.layout = layout; cfg.baseline = [-0.05, 0]; cfg.xlim = [-0.05, 0.35];
% cfg.channel = [1, 3:126];
% figure; ft_multiplotER(cfg, avgF, avgN);
% 
% %%
% avg = ft_timelockanalysis(cfg, data_ar);
