% have a look at the filter
nTheta  = 8;
sigma_p = .1;
sigma_g = .85;
sigma_s = .01;
sz      = 30;
kernel_w = kernel_weight( sigma_p, sigma_g, sigma_s, sz );
for theta1 = 1: nTheta
    for theta2 = 1:nTheta 
        % subplot( 8, 8, (theta1-1)*nTheta + theta2)
        % imshow( squeeze(kernel_w( :, :, theta1, theta2)), []);
        axis off
    end  
end 

% show the normalization shape
E_xy = dataloader( stdnormRootPath, 'E_xy', 'target', 1, 1);

% choose thete
theta = 1;
curves = squeeze(E_xy( :, :, :, 1, 3));
gratings = squeeze(E_xy( :, :, :, 1, 8));

% 
blue = [52, 152, 219]./255;
red  = [231, 76, 60]./255; 
stims = [ 3, 8];
for idx = 1:2
    Z = NaN(8,1);
    stim = stims(idx);
    for ep = 1 
        E = squeeze(mean(mean(E_xy( :, :, :, ep, stim),2),1));
        
        Z2 = NaN(nTheta, 1);
        for theta1 = 1:nTheta
            sum_img = 0;
            F2 = squeeze(kernel_w( :, :, :, theta1));
            Ex = squeeze(E_xy( :, :, theta1, ep, stim));
            Ex = repmat( Ex, 1, 1, 8);
            
            for theta2 = 1:nTheta
                %subplot( 6, 4, theta2)
                F = squeeze(kernel_w( :, :, theta2, theta1));
                %imshow( F, []);
                %subplot( 6, 4, 8+theta2)
                img = squeeze(E_xy( :, :, theta2, ep, stim));
                %imshow( img, [0, .25])
                %subplot( 6, 4, 16+theta2)
                c_img = conv2( img, F, 'same');
                %imshow( c_img, [0, .1])
                sum_img = sum_img + c_img / nTheta;
            end
            Z( theta1, 1) = mean(sum_img(:));   
            c =squeeze(mean(convn( Ex, F2, 'same'), 3));
            Z2( theta1, 1) = mean(c(:)) / 8;
        end    
    end
    subplot( 1, 2, idx)
    plot( E, 'color', blue, 'linewidth', 5)
    ylim( [ 0, .01])
    hold on 
    plot( Z, 'color', red, 'linewidth', 5)
    plot( Z2, 'color', 'k', 'linewidth', 5)
    legend( 'E', 'Z', 'Z2')
    ylim( [ 0, .01])
    box off
    
end 





