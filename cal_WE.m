function E = cal_WE( E_xy, labelVec )
%% Set up filter and print

sigma_p=.1;
sigma_g=.85;
sigma_s=.01;

sz = round(size(E_xy, 1) / 20)*2;
kernel_w = kernel_weight( sigma_p, sigma_g, sigma_s, sz );

%% Run the ori-suround

E = nan( size(E_xy));
w_e_sum_theta = nan( size(E_xy,1), size(E_xy,2), size(E_xy,3) );

idx = round((1:10)/10*length(labelVec));
fprintf('\n');

for ii= 1:length(labelVec)
    
    label = labelVec(ii);
    if ismember(ii, idx), fprintf('.'); end

    for ep = 1: size(E_xy,4)
                        
        % select E
        E_im = E_xy( :, :, :, ep, label ); % Reduce from 5D to 3D
        
        % size of orientation
        nL=size(kernel_w, 4);
        
        % Remap response_3D to create a response have the same value on the 4th
        % dimension, \theta_prime
        E_4D = repmat( E_im, [ 1, 1, 1, nL ]); % response_4D: x, y, \theta, \theta_prime
        
        % Make a 3 dimension convolution, with x, y and \theta_prime
        for theta = 1:nL
            
            % fprintf('Label: %d\tEP: %d\ttheta: %d\n', ii, ep, theta);
            
            % Choose the appropriate kernerl_weight and e_1 contrast energy image
            kernel_w_prime = squeeze( kernel_w( :, :, theta, : ));
            image_3D_S = squeeze( E_4D( :, :, theta, : )); %3D,
            
            % Do the convolution to combine weight and e_1 contrast energy image
            w_e = convn( image_3D_S, kernel_w_prime, 'same' ); %weigthed_e_1:  x, y, \theta_prime
            
            % Squeeze this 3-D weighted energy map into 2-D (In another word, sum
            % over \theta_prime
            w_e_sum = squeeze( mean( w_e, 3 ) );  %weigthed_e_1:  x, y
            
            % Assign the result into d_1
            w_e_sum_theta(:, :, theta) = w_e_sum; %weigthed_e_1:  x, y, \theta
        end
        
        E( :, :, :, ep, label) =  w_e_sum_theta;
    end
end
fprintf('\n');

