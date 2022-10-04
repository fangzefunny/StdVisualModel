
function [Gabor_c, Gabor_s] = get_Filters(data, ds, filter_cpd)
if (nargin < 1), filter_cpd = 3;end % default is 3 cyc/deg 

fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(ds);
numpix      = size(data,1);
pixperdeg   = numpix / fov;
ppc         = pixperdeg ./ filter_cpd; % pixels per cycle
support     = 6; % cycles per filter
o           = linspace(0,pi, 9); % orientation
thetavec    = o(1:end-1); % exclude the pi deg

% create filters
[Gabor_c, Gabor_s] = makeGaborFilter(ppc, thetavec, support);
end