%%

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';                                                   %compute the power spectrum in all ICs
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
