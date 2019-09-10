function [Gabor_cos,Gabor_sin]= makeGaborFilter(ppcvec, thetavec, support)
 
if ~exist('support', 'var') || isempty(support)
    support = 2; % 2 cycles per filter
end

numOrientations = length(thetavec);
numFrequencies  = length(ppcvec);

% cell arrays for filters
Gabor_cos = cell(numOrientations,numFrequencies); 
Gabor_sin = cell(numOrientations,numFrequencies); 


for f = 1:numFrequencies
    ppc = ppcvec(f);    
    numPix= round(ppc * support); % number of pixels in 2 cycles
    [x, y] = meshgrid((1:numPix)/ppc);
    for o = 1:numOrientations
        theta = thetavec(o);
        
        % Rotation the 2D gabors
        wave_c = cos(theta);
        wave_s = sin(theta);

        % complex harmonic
        h = exp(1i*(wave_c*x+wave_s*y)*pi*2);
        
        % Gauss with spatial frequency
        Gauss = fspecial('gauss',numPix, numPix/4);
        
        % 2D Gabor
        Gabor_A = Gauss.*h;
        
        % subtract mean to make sure its mean is 0
        Gabor_A = Gabor_A - mean(Gabor_A(:));
       
        % Cos Gabor
        Gabor_c = imag(Gabor_A);
        Gabor_s = real(Gabor_A);
        
        %Normalization
        norm_Gabor_c=Gabor_c.*1/norm(Gabor_c);
        norm_Gabor_s=Gabor_s.*1/norm(Gabor_s);
       
        
        % Scale the gobors
        Gabor_cos{ o,f}=norm_Gabor_c;
        Gabor_sin{o,f}=norm_Gabor_s;
        
    end
end

