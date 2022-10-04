function Z = cal_Z(E_xy, mode, sig_long, sig_short, sig_dot)

%  Calculate the normalization of the OTS
%
%    Args:
%        E_xy: a 5-D matrix, contrast energy
%        labelVec: an array, tell the label of the dataset
%        mode: oriTuned or notTuned
%        sig_long: the sigma of the longer side
%        sig_short: the sigma of the shorter side
%        sig_dot: the sigma of the local suppression
%    
%    Returns:
%        Z: a 5-D matrix, normalization

% set the default parameter

if (nargin < 2), mode      = 'oriTuned'; end
if (nargin < 3), sig_long  = .8; end
if (nargin < 4), sig_short = .8; end
if (nargin < 5)
    switch mode
        case 'oriTuned'
            sig_dot = .01; 
        otherwise 
            sig_dot = sig_long; 
    end 
end

sz = round(size(E_xy, 1) / 20)*2;
labelVec = 1:size(E_xy, 5);

% get the filter
F = kernel_weight(sig_long, sig_short, sig_dot, sz, mode);
nO = size(F, 4);

% holders
Z = nan( size(E_xy));
idx = round((1:10)/10*length(labelVec));
fprintf('\n');

% for all images
for ii= 1:length(labelVec)
    
    % track progress
    if ismember(ii, idx), fprintf('.'); end
    label = labelVec(ii);

    % for all examples
    for ep = 1: size(E_xy,4)

        % select E
        E_im = E_xy(:, :, :, ep, label); % Reduce from 5D to 3D

        % init 
        Z_thetas = NaN(size(E_im,1), size(E_im,2), nO);
        
        % choose the θ for E(x,y,θ)
        for theta1 = 1:nO % θ
            
            Z_theta1 = 0;
            for theta2 = 1:nO % θ'

                % choose the appropriate kernerl_weight and e_1 contrast energy image
                kernel_w_2D = squeeze(F(:, :, theta1, theta2)); % xy
                image_theta = squeeze(E_im(:, :, theta2)); % xy

                % do the convolution to combine weight and e_1 contrast energy image
                % z(x,y,θ') = E(x-x',y-y';θ=i) F(x',y';θ=i,θ2)
                z_theta = conv2(image_theta, kernel_w_2D, 'same'); % xy . xy = xy
                
                % Z(x,y;θ=i）= ∑_θ' z(x,y,θ') 
                Z_theta1 = Z_theta1 + z_theta;
            end
            
            % Z(x,y,θ)
            Z_thetas(:, :, theta1) = Z_theta1;

        end
                    
        Z(:, :, :, ep, label) = Z_thetas; %Z: xyθ
                    
    end
end
 
fprintf('\n');
end

