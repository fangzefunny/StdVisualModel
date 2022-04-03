function Z = calc_z(E, F)

% init the Z
Z = nan( size(E));

% get the number of orientation
nT = size( F, 4);

% choose the θ for E(x,y,θ)
for ep = 1:size(E,4)
    for theta1 = 1:nT
        
        % init a sum Z(x,y;θ=i)
        Z_theta1 = 0;
        for theta2 = 1:nT
            
            % Choose the appropriate kernerl_weight and e_1 contrast energy image
            kernel_w_2D = squeeze( F( :, :, theta1, theta2)); % xy
            image_theta = squeeze( E( :, :, theta1, ep)); % xy
            
            % Do the convolution to combine weight and e_1 contrast energy image
            z_theta2 = conv2( image_theta, kernel_w_2D, 'same'); % xy . xy = xy
            
            % Z(x,y;θ=i）= ∑_θ2 E(x-x',y-y';θ=i) F(x',y';θ=i,θ2)
            Z_theta1 = Z_theta1 + z_theta2;
        end
        
        % Assign the result into Z
        Z(:, :, theta1, ep) = Z_theta1; %Z: xyθ
    end
end
end

