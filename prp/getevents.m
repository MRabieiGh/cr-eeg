function trl = getevents(fname, wh)
%GETEVENTS Summary of this function goes here
%   Detailed explanation goes here

if (nargin < 2), wh = "timestamps"; end

load(fname)

if  wh == "timestamps"
events = floor(events(:, 1) / 1200 * 500);
trl = [events-500*0.5, events+500*1-1, -500*0.5*ones(size(events))];
elseif wh == "trialinfo"
    trl = events(:, 2);
end

end

