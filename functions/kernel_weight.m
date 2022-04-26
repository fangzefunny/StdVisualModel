function F1 = kernel_weight(sigma_p,sigma_g,sigma_s, numx)

numthetas   = 8; % The number of the \theta in the parameter 
thetas      = (0:numthetas-1)*pi/numthetas; % \theta vector  
if ~exist('numx', 'var') || isempty(numx); numx = 40; end
xs          = linspace(-1,1,numx);% x axis 
ys          = linspace(-1,1,numx);% y axis 

% a 3-d meshgrid 
[x, y, th] = meshgrid(xs, ys, thetas);
F = nan(numx, numx, numthetas, numthetas);

for theta = thetas
    
    % theta1: the orientation of the contrast energy 
    theta_prime = theta*numthetas/pi + 1;
    x2 = zeros(size(x));
    y2 = zeros(size(y));
    
    % roatate the plane 
    for ii = 1:numthetas
        R = [cos(thetas(ii)) sin(thetas(ii));
            -sin(thetas(ii)) cos(thetas(ii))];
        thisx = x(:, :, ii);
        thisy = y(:, :, ii);
        tmp = R * [thisx(:), thisy(:)]';
        x2(:, :, ii) = reshape(tmp(1, :), [numx, numx]);
        y2(:, :, ii) = reshape(tmp(2, :), [numx, numx]);
    end
 
    % build an unoriented suppression field near the image center
    G = exp(- ( y.^2./(2*sigma_s^2)+ x.^2./(2*sigma_s^2)));
    
    % make the surround suppression orientation tuned
    idx = thetas == theta;
    G(:,:,idx) = exp(-(y2(:,:,idx).^2./(2*sigma_p^2) + x2(:,:,idx).^2./(2*sigma_g^2)));
    
    F(:,:,:,theta_prime) = G(:,:,:) / sum(G(:));
end

% change the sequence
F1 = F;
F1(:, :, 1:4, 1:4) = F(:, :, 5:8, 5:8);
F1(:, :, 5:8, 5:8) = F(:, :, 1:4, 1:4);
F1 = F1 ./ sum(F1, [1,2,3]);
end
