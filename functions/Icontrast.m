
function [response]=Icontrast(stimulus,G_c,G_s, sfvec, thetavec)

% Parameter setting
nf=length(sfvec);
nO=length(thetavec);
ni=size(stimulus,1);

response = nan( ni, ni, nO, nf );

for sfind = 1:nf
    
    for thetaind = 1:length(thetavec)
        % Extract the Gabor filters
        Gabor_c = G_c{thetaind,sfind};
        Gabor_s = G_s{thetaind,sfind};
        
        % First Order Output
        out_stim1 = sqrt((conv2(stimulus,Gabor_c,'same').^2 ...
                                        +conv2(stimulus,Gabor_s,'same').^2));

        % Put the output into a 4-d matrix
        response(:,:,thetaind, sfind) = out_stim1;
        %response_1x((1+ni*(nF-sfind)):ni*(nF+1-sfind),(1+ni*(thetaind-1)):ni*(thetaind)) = out_stim1;
       
    end
end



