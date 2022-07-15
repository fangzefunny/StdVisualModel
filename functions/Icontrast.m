
function conEnergy = Icontrast(stimulus, G_c, G_s)

% contrast image size 
sz = size(stimulus,1);
[nT, nF] = size(G_c);

% placeholders 
conEnergy = nan(sz, sz, nT, nF);

% for all frequencies, 
% in this project, there is only 1 frequency
for i = 1:nF
    % for all orientaitons 
    for j = 1:nT
        
        % get the Gabor filters
        Gabor_c = G_c{j, i};
        Gabor_s = G_s{j, i};
        
        % compute the energy 
         CE = conv2(stimulus,Gabor_c,'same').^2 ...
            + conv2(stimulus,Gabor_s,'same').^2;
         conEnergy(:, :, j, i) = CE; 
    end
end

% combine the spatial frequencies
conEnergy = sum(conEnergy, 4);

end



