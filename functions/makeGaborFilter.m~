function [Gabor_cos,Gabor_sin]= makeGaborFilter(ppcvec, thetavec, support)
 
if ~exist('support', 'var') || isempty(support)
    support = 3; % 3 cycles per filter --// 
end

numOrientations = length(thetavec);
numFrequencies  = length(ppcvec);

% cell arrays for filters
Gabor_cos = cell(numOrientations,numFrequencies); 
Gabor_sin = cell(numOrientations,numFrequencies); 


for f = 1:numFrequencies
    ppc = ppcvec(f);    
    numPix= round(ppc * support); % number of pixels in 2 cycles
    [x, y] = meshgrid((0:numPix-1)/ppc);

    % Gauss with spatial frequency
    Gauss = fspecial('gauss',numPix, numPix/support);

    for o = 1:numOrientations
        theta = thetavec(o);
        
        % Rotation the 2D gabors
        wave_c = cos(theta);
        wave_s = sin(theta);

        % complex harmonic
        h = exp(1i*(wave_c*x+wave_s*y)*pi*2);
              
        % 2D Gabor
        % Gabor_A = Gauss.*h;
        
        % subtract mean to make sure its mean is 0
        % Gabor_A = Gabor_A - mean(Gabor_A(:));
       
        % Cos Gabor
        Gabor_c = Gauss.*imag(h);
        Gabor_s = Gauss.*real(h);
        
        %Normalization
        norm_Gabor_c=Gabor_c.*1/norm(Gabor_c(:));
        norm_Gabor_s=Gabor_s.*1/norm(Gabor_s(:));
       
        
        % Scale the gobors
        Gabor_cos{o,f}=norm_Gabor_c;
        Gabor_sin{o,f}=norm_Gabor_s;
        
    end
end

