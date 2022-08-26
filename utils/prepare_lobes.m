clc
clear

locations = readmatrix("locations.txt", ...
    'Delimiter', '\t', ...
    'OutputType', 'string', ...
    'NumHeaderLines', 0);

lobes = strtrim(mat2cell(char(locations(:, 6)), ones(126, 1)));

save lobes128.mat lobes
% save chnames.mat label