
function conEnergy = Icontrast(stimulus,G_c,G_s, sfvec, thetavec)

% contrast image size 
sz = size(stimulus,1);

% placeholders 
conEnergy = nan(sz, sz, length(thetavec), length(sfvec));

% for all frequencies, 
% in this project, there is only 1 frequency
for i = 1:length(sfvec)
    % for all orientaitons 
    for j = 1:length(thetavec)
        
        % get the Gabor filters
        Gabor_c = G_c{j, i};
        Gabor_s = G_s{j, i};
        
        % compute the energy 
        conEnergy(:, :, j, i) = conv2(stimulus,Gabor_c,'same').^2 ...
                              + conv2(stimulus,Gabor_s,'same').^2;       
    end
end

% remove the frequency dimension 
conEnergy = squeeze(conEnergy);

end



