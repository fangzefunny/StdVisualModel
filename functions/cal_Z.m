function Z = cal_Z( E_xy, labelVec )
%% Set up filter and print

sigma_p=.1;
sigma_g=.85;
sigma_s=.01;

sz = round(size(E_xy, 1) / 20)*2;
kernel_w = kernel_weight( sigma_p, sigma_g, sigma_s, sz );

%% Run the ori-suround
Z = nan( size(E_xy));
idx = round((1:10)/10*length(labelVec));
fprintf('\n');

for ii= 1:length(labelVec)
    
    label = labelVec(ii);
    if ismember(ii, idx), fprintf('.'); end

    for ep = 1: size(E_xy,4)
                        
        % select E
        E_im = E_xy( :, :, :, ep, label ); % Reduce from 5D to 3D
        
        % size of orientation
        nT=size(kernel_w, 4);

        % choose the θ for E(x,y,θ)
        for theta1 = 1:nT
            
            % fprintf('Label: %d\tEP: %d\ttheta: %d\n', ii, ep, theta);

            % init a sum Z(x,y;θ=i)
            Z_theta1 = 0;
            for theta2 = 1:nT
            
                % Choose the appropriate kernerl_weight and e_1 contrast energy image
                kernel_w_2D = squeeze( kernel_w( :, :, theta1, theta2 )); % xy
                image_theta = squeeze( E_im( :, :, theta1)); % xy 
                
                % Do the convolution to combine weight and e_1 contrast energy image
                z_theta2 = conv2( image_theta, kernel_w_2D, 'same' ); % xy . xy = xy 
                
                % Z(x,y;θ=i）= ∑_θ2 E(x-x',y-y';θ=i) F(x',y';θ=i,θ2)
                Z_theta1 = Z_theta1 + z_theta2;
            end 

            % Assign the result into Z
            Z(:, :, theta1, ep, label) = Z_theta1; %Z: xyθ
        end
    end
end
fprintf('\n');

