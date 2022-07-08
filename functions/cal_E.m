function E = cal_E(data, labelVec, mode, which_data, filter_cpd)
if (nargin < 5), filter_cpd = 3;end

fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(which_data);
numpix      = size(data,1);
pixperdeg   = numpix / fov;
ppc         = pixperdeg ./ filter_cpd; % pixels per cycle
support     = 6; % cycles per filter
o           = linspace(0,pi, 9); % orientation
thetavec    = o(1:end-1); % exclude the pi deg
nO          = length(thetavec);
padsize     = max(ppc) .* support;

% create filters
[Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);

% get placeholders,
switch mode
    case 'orientation'
        % dims: ori x ep x labels
        E = nan(nO, 9, length(labelVec));
    case 'space'
        % The size the size
        sz = numpix + padsize*2;
        % dims: X x Y x ori x ep x labels
        E = nan(sz, sz, nO, 9, length( labelVec ));
end

% progress tracking
idx = round((1:10)/10*length(labelVec));
fprintf('\n');

for ii= 1:length(labelVec)
    if ismember(ii, idx), fprintf('.'); end
    
    % the stimululi label
    label = labelVec(ii);
    for ep = 1 : 9 % Each have 9 examples.
        
        % get the stimulus and pad the stimulus
        stimulus = data(:, :, ep, label);
        padstimulus = zeros(numpix+padsize*2, numpix+padsize*2);
        padstimulus(padsize+(1:numpix), padsize+(1:numpix)) = stimulus;
        stimulus = padstimulus;
        
        % filter and get the CONTRAST of the image
        % dims: X x Y x ori
        conEnergy = Icontrast(stimulus, Gabor_c, Gabor_s, ppc, thetavec); 
           
        % assign the data
        switch mode
            case 'orientation'
                % create a disk-like weight to prevent edge effect
                w = gen_disk(size(conEnergy, 1));
                % calculate E_ori for orientation-type model
                E_ori = squeeze(mean(mean(w.*conEnergy, 2), 1)); % 1- D theta
                E(:, ep, ii) = E_ori';
            case 'space'
                E(:, :, :, ep,  ii) = conEnergy;   
        end
    end
end
fprintf('\n');
end
