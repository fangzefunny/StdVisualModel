function E = cal_WE( E_xy, labelVec, which_data )
%% Set up filter and print

sigma_p=.1;
sigma_g=.85;
sigma_s=.01;

kernel_w = kernel_weight( sigma_p, sigma_g, sigma_s );

%% Run the ori-suround

if which_data  ~= 2
    E = nan( 480, 480, 8, 9, length( labelVec ) );
    w_e_sum_theta = nan( 480, 480, 8 );
elseif which_data == 2
    E = nan( 680, 680, 8, 9, length( labelVec ) );
    w_e_sum_theta = nan( 680, 680, 8 );
end

for ii= 1:length(labelVec)
    
    label = labelVec(ii)
    
    for ep = 1: 9
        
        ep
        
        % select E
        E = E_xy( :, :, :, ep, label ); % Reduce from 5D to 3D
        
        % size of orientation
        nL=size(kernel_w, 4);
        
        % Remap response_3D to create a response have the same value on the 4th
        % dimension, \theta_prime
        E_4D = repmat( E, [ 1, 1, 1, nL ]); % response_4D: x, y, \theta, \theta_prime
        
        % Make a 3 dimension convolution, with x, y and \theta_prime
        for theta = 1:nL
            
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


