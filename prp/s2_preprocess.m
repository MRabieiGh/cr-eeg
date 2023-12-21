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
data.label   = layout.label(1:end-2);
data.elec    = layout.cfg.elec;
data.fsample = 1200;
data.trial   = {d};
data.time    = {(1:size(d, 2)) / data.fsample};

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
    tmp = ft_databrowser(cfg, data);
    [index, ~] = listdlg('ListString', layout.label(1:end-2));
    clear tmp

    bad_channels = data.label(index);
    writecell(bad_channels, fullfile(path, 'bad_channels.csv'))
else
    bad_channels = readcell(fullfile(path, 'bad_channels.csv'));
end

if ~isempty(bad_channels)
    cfg         = [];
    cfg.method  = 'triangulation';
    cfg.channel = data.label;
    cfg.elec    = data.elec;
    neighbours  = ft_prepare_neighbours(cfg, data);
    
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

%% Omit the First 5 Seconds of Data
ind = (5*data.fsample):length(data.time{1});
data.time{1} = data.time{1}(ind);
data.trial{1} = data.trial{1}(:, ind);
data.sampleinfo(1) = 5*data.fsample;

%% ICA Training
if ~isfile(fullfile(path, 'components.mat'))
    cfg            = [];
    cfg.method     = 'runica';
    cfg.runica.pca = 126 - length(bad_channels); % If there are interpolated channels, 126 - NumInterpol
    components     = ft_componentanalysis(cfg, data);
    save(fullfile(path, 'components.mat'), 'components')

    save(fullfile(path, 'components.mat'), 'components')
else
    components = load(fullfile(path, 'components.mat')).components;
end

clear bad_channels


%% Component Rejection
if ~isfile(fullfile(path, 'bad_components.csv'))
    cfg          = [];
    cfg.channel  = 1:20; % components to be plotted
    cfg.viewmode = 'component';
    cfg.layout   = layout; % specify the layout file that should be used for plotting
    cfg.component = 1:20;
    tmp = ft_databrowser(cfg, components);
end

%% 
if ~isfile(fullfile(path, 'bad_components.csv'))
    [index, ~] = listdlg('ListString', string(1:20));

    bad_components = index;
    writematrix(bad_components, fullfile(path, 'bad_components.csv'))
else
    bad_components = readmatrix(fullfile(path, 'bad_components.csv'));
end

if ~isempty(bad_components)
    cfg = [];
    cfg.component = bad_components;
    data = ft_rejectcomponent(cfg, components, data);
end

clear index tf bad_components

%% Make Data Epochs(Trials)
cfg = [];
cfg.trl = getevents(fullfile(path, 'events.mat'));
data = ft_redefinetrial(cfg, data);
data.trialinfo = getevents(fullfile(path, 'events.mat'), 'trialinfo');

%% Reject Bad Trials
if ~isfile(fullfile(path, 'good_trials.csv'))
    cfg         = [];
    cfg.method  = 'summary';
    data_ar     = ft_rejectvisual(cfg, data);
    good_trials = data_ar.cfg.trials;

    writematrix(good_trials', fullfile(path, 'good_trials.csv'))
else
    good_trials = readmatrix(fullfile(path, 'good_trials.csv'));
end

cfg = [];
cfg.trials = good_trials;
data = ft_selectdata(cfg, data);

clear index tf good_trials

%%
subjectName = regexp(path, '\', 'split');
subjectName = lower(subjectName{end});
save(fullfile('G:\Data\EEG', ...
    strcat('ft_', replace(subjectName, '-', '_'))), 'data')

%%
% lbl = grablabels('face-body'); lbl = lbl(1:155);
% fac = find(lbl == 0);
% bod = find(lbl == 1);
% lbl = grablabels('artificial-natural'); lbl = lbl(1:155);
% art = find(lbl == 0);
% nat = find(lbl == 1);
% 
% categories = NaN(1, nStimuli);
% categories(fac) = 0;
% categories(bod) = 1;
% categories(art) = 2;
% categories(nat) = 3;
% bad_stim = isnan(categories);
% 
% categories(bad_stim) = [];
% X(bad_stim, :, :) = [];
% y = categories;
