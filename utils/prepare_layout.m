clc
clear

locations = readmatrix("location_xyz.txt", ...
    'Delimiter', '\t', ...
    'OutputType', 'string', ...
    'NumHeaderLines', 0);

label = strtrim(mat2cell(char(locations(:, 5)), ones(126, 1)));
elec.label   = label;
elec.elecpos = str2double(locations(:, 2:4));
elec.chanpos = str2double(locations(:, 2:4));
cfg = [];
cfg.elec = elec;
[layout, ~] = ft_prepare_layout(cfg);

save eeg128.mat layout
% save chnames.mat label