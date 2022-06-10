function Z = cal_Z(E_xy, labelVec, sig_long, sig_short, sig_dot)
%{ 
    Calculate the normalization of the OTS
    
    Args:
        E_xy: a 5-D matrix, contrast energy 
        labelVec: an array, tell the label of the dataset 
        sig_long: the sigma of the longer side
        sig_short: the sigma of the shorter side
        sig_dot: the sigma of the local suppression
    
    Returns:
        Z: a 5-D matrix, normalization
%}

% set the default parameter 
if (nargin < 5), sig_dot   = .01; end
if (nargin < 4), sig_short = .1; end
if (nargin < 3), sig_long  = .85; end
sz = round(size(E_xy, 1) / 20)*2;

% get the filter 
F = kernel_weight(sig_long, sig_short, sig_dot, sz);
nO = size(F, 4);

% holders
Z = nan( size(E_xy));
idx = round((1:10)/10*length(labelVec));
fprintf('\n');

% for all orientaitons
for ii= 1:length(labelVec)
    % track progress
    if ismember(ii, idx), fprintf('.'); end
    label = labelVec(ii);
    
    % for all examples
    for ep = 1: size(E_xy,4)
        
        % select E
        E_im = E_xy(:, :, :, ep, label); % Reduce from 5D to 3D
        
        % choose the θ for E(x,y,θ)
        for theta1 = 1:nO
            
            % init a sum Z(x,y;θ=i)
            Z_theta1 = 0;
            for theta2 = 1:nO
                
                % choose the appropriate kernerl_weight and e_1 contrast energy image
                kernel_w_2D = squeeze(F(:, :, theta1, theta2)); % xy
                image_theta = squeeze(E_im(:, :, theta1)); % xy
                
                % do the convolution to combine weight and e_1 contrast energy image
                z_theta2 = conv2(image_theta, kernel_w_2D, 'same'); % xy . xy = xy
                
                % Z(x,y;θ=i）= ∑_θ2 E(x-x',y-y';θ=i) F(x',y';θ=i,θ2)
                Z_theta1 = Z_theta1 + z_theta2;
            end
            
            % Assign the result into Z
            Z(:, :, theta1, ep, label) = Z_theta1; %Z: xyθ
        end
    end
end
fprintf('\n');
end

