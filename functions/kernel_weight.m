function Gauss1= kernel_weight (sigma_p,sigma_g,sigma_s, numx )

numthetas   = 8; % The number of the \theta in the parameter 
thetas      = (0:numthetas-1)*pi/numthetas; % \theta vector  

if ~exist('numx', 'var') || isempty(numx)
    numx = 40; % How large the kernel should be
end

xs          = linspace(-1,1,numx);% x axis 
ys          = linspace(-1,1,numx);% y axis 

[x, y, th] = meshgrid(xs, ys, thetas) ; % Build a 3-D matrix, which is the based of our kernel



for theta = thetas
    % build kernel for first theta
    theta_prime = theta*numthetas/pi +1;
    
    for ii = 1:numthetas
        R{ii} = [cos(thetas(ii)) sin(thetas(ii));
                 -sin(thetas(ii)) cos(thetas(ii))];
    end
    
    x2 = zeros(size(x));
    y2 = zeros(size(y));
    
    for ii = 1:numthetas
        thisx = x(:,:,ii);
        thisy = y(:,:,ii);
        tmp = R{ii} * [thisx(:), thisy(:)]';
        x2(:,:,ii) = reshape(tmp(1,:), [numx, numx]);
        y2(:,:,ii) = reshape(tmp(2,:), [numx, numx]);
    end
    
 
    % Build an unoriented suppression field near the image center
    G = exp(- ( y.^2./(2*sigma_s^2)+ x.^2./(2*sigma_s^2)));
    
    % Make the surround suppression orientation tuned
    idx = thetas == theta;
    G(:,:,idx) = exp(- ( y2(:,:,idx).^2./(2*sigma_p^2) + x2(:,:,idx).^2./(2*sigma_g^2)));
    
    Gauss(:,:,:,theta_prime) = G(:,:,:) / sum( G(:) );
end
Gauss1 = 8.*Gauss./sum(Gauss(:));