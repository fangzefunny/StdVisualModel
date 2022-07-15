function [E_ori, E] = cal_E(data, ds, Gabor_c, Gabor_s)

% define the orientation
o        = linspace(0,pi, 9); % orientation
thetavec = o(1:end-1); % exclude the pi deg
nO       = length(thetavec);
labelVec = 1:size(data, 4);

% get the size of the pad image
numpix  = size(data,1);
re_szs  = [150, 225, 150, 150]; 
support = 6;
padsize = 12 .* support; % need to check
re_sz   = re_szs(ds) + ceil(padsize*re_szs(ds)/numpix)*2;

% get placeholders,
% dims: X x Y x ori x ep x labels
E = nan(re_sz, re_sz, nO, 9, length(labelVec));
E_ori = nan(nO, 9, length(labelVec));

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
        conEnergy = Icontrast(stimulus, Gabor_c, Gabor_s);
        
        % get E_ori and E space
        % create a disk-like weight to prevent edge effect
        w = gen_disk(size(conEnergy, 1));
        % calculate E_ori for orientation-type model
        E_o = squeeze(mean(mean(w.*conEnergy, 2), 1)); % 1- D theta
        E_ori(:, ep, ii) = E_o';
        E(:, :, :, ep,  ii) = imresize(conEnergy, [re_sz, re_sz]);
    end
end

fprintf('\n');
end

