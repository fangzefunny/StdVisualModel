function [a1, a2] = OTSFilters(Fil_typ, Data_typ, ds, roi)
%{
    Investigate different normalization fitlers

    Args:
        Fil_typ -'Round-oriTune': circle filters that are orientation
                    tuned
                -'Elipse-nonTune': elipse filters that are not orientation
                    tuned
                -'Elipse-oriTune':
        Data_type: kinds of data we want
                    - 'Filters':
                    - 'Get data':
                    - 'E_mean':
                    - 'Z_mean':
                    - 's':
        ds: data set
        roi: visual cortex. 1, 2, 3
%}
% get the default value
if (nargin < 4), roi = 1; end
if (nargin < 3), ds = 1; end
if (nargin < 2), Data_typ = false; end

a1 = nan;
a2 = nan;
switch ds
    case 1; tar_ind = [1:5;6:10;15,16,3,17,18;11,12,8,13,14]; N=18;
    case 4; tar_ind = [9:12, 26, 28:39];
end

%---------------------------------------------
% Edit here!!
% make w list
w_Lst    = [.1, 1, 10, 100, 10000, 1e6];
nW = length(w_Lst);
% get the grid search value
sig_Lst  = linspace(.1, .85, 5);
nS = length(sig_Lst);
%---------------------------------------------

% save_dir
save_address = fullfile(stdnormRootPath, 'analyses', 'data');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% colors
curvy   = [  .4,  .4,  .4] + .1;
grating = [  .6,  .6,  .6] + .1;

% load E
E = dataloader(stdnormRootPath, 'E_xy',...
    'target', ds, roi);

switch Fil_typ
    
    case 'Round-oriTune'
        
        switch Data_typ
            
            case 'Filters'
                
                % some values
                show_sig_Lst = [.2, .85];
                
                % create OTS filters
                for i=1:length(show_sig_Lst)
                    
                    % equate the long and the short side
                    sig_long  = show_sig_Lst(i);
                    sig_short = show_sig_Lst(i);
                    sig_dot   = .01;
                    sz = round(size(E, 1)/20)*2;
                    F = kernel_weight(sig_long, sig_short, sig_dot, sz);
                    
                    % visualize the filters
                    figure();
                    for j = 1:8
                        for k = 1:8
                            subplot(8, 8, (j-1)*8+k)
                            imshow(F(:,:,j,k), [])
                        end
                    end
                    sgtitle(sprintf('sig_L=%02g, sig_S=%02g', sig_long, sig_short))
                end
                
            case 'Get data'
                
                % save E mean
                E_mean = squeeze(mean(E, [1,2,3,4]));
                fname = sprintf('E_mean-ds%02d-roi%02d.mat', ds, roi);
                save(fullfile(save_address, fname), 'E_mean');
                
                % some values
                sz = size(E);
                labelVec = 1:sz(end);
                model = oriSurroundModel('fmincon', 1);
                model = model.disk_weight(model, size(E, 1));
                
                % create OTS filters
                for i = 1:length(sig_Lst)
                    
                    % equate the long and the short side
                    sig_long  = sig_Lst(i);
                    sig_short = sig_Lst(i);
                    sig_dot   = .01;
                    Z = cal_Z(E, labelVec, sig_long, sig_short, sig_dot);
                    
                    % try different w
                    for j = 1:length(w_Lst)
                        
                        % get w
                        w = w_Lst(j);
                        
                        % calculate the normalized energy d
                        % E_xy: [x, y, theta, ep, stim]
                        Z_mean = squeeze(mean(Z, [1,2,3,4]));
                        d = E ./ (1 + w * Z);
                        v = squeeze(mean(d, 3));
                        d = bsxfun(@times, v, model.receptive_weight);
                        s = squeeze(mean(d, [1, 2, 3]));
                        
                        % save data
                        fname = sprintf('z_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig_long, sig_short, ds, roi);
                        save(fullfile(save_address, fname), 'Z_mean');
                        fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig_long, sig_short, ds, roi);
                        save(fullfile(save_address, fname), 's');
                    end
                end
                
            case 's'
                
                % get the data
                BOLD_ben = nan(nW, N);
                BOLD_hat = nan(nW, nS, N);
                for i = 1:length(w_Lst)
                    
                    w = w_Lst(i);
                    fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                        w, 0.85, 0.1, ds, roi);
                    load(fullfile(save_address, fname), 's');
                    s_scale = s ./ s(1);
                    BOLD_ben(i, :) = s_scale;
                    
                    for j = 1:length(sig_Lst)
                        
                        sig = sig_Lst(j);
                        fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig, sig, ds, roi);
                        load(fullfile(save_address, fname), 's');
                        s_scale = s ./ s(1);
                        BOLD_hat(i, j, :) = s_scale;
                        
                    end
                end
                disp('return scaled simulation and benchmark for')
                disp('   w in')
                disp(w_Lst)
                disp('   sigma in')
                disp(sig_Lst)
                a1 = BOLD_hat;
                a2 = BOLD_ben;
                
        end
        
    case 'Elipse-oriTune'
        
        switch Data_typ
            
            case 'Filters'
                
                % load E
                E = dataloader(stdnormRootPath, 'E_xy',...
                    'target', ds, roi);
                
                % some values
                sig_Lst = [.2, .85];
                
                % create OTS filters
                for i=1:length(sig_Lst)
                    
                    % equate the long and the short side
                    sig_long  = sig_Lst(i);
                    sig_short = .1;
                    sig_dot   = .01;
                    sz = round(size(E, 1)/20)*2;
                    F = kernel_weight(sig_long, sig_short, sig_dot, sz);
                    
                    % visualize the filters
                    figure();
                    for j = 1:8
                        for k = 1:8
                            subplot(8, 8, (j-1)*8+k)
                            imshow(F(:,:,j,k), [])
                        end
                    end
                    sgtitle(sprintf('sig_L=%02g, sig_S=%02g', sig_long, sig_short))
                end
                
            case 'Get data'
                
                % save E mean
                E_mean = squeeze(mean(E, [1,2,3,4]));
                fname = sprintf('E_mean-ds%02d-roi%02d.mat', ds, roi);
                save(fullfile(save_address, fname), 'E_mean');
                
                % some values
                sz = size(E);
                labelVec = 1:sz(end);
                model = oriSurroundModel('fmincon', 1);
                model = model.disk_weight(model, size(E, 1));
                
                % create OTS filters
                for i = 1:length(sig_Lst)
                    
                    % equate the long and the short side
                    sig_long  = sig_Lst(i);
                    sig_short = .1;
                    sig_dot   = .01;
                    Z = cal_Z(E, labelVec, sig_long, sig_short, sig_dot);
                    
                    % try different w
                    for j = 1:length(w_Lst)
                        
                        % get w
                        w = w_Lst(j);
                        
                        % calculate the normalized energy d
                        % E_xy: [x, y, theta, ep, stim]
                        Z_mean = squeeze(mean(Z, [1,2,3,4]));
                        d = E ./ (1 + w * Z);
                        v = squeeze(mean(d, 3));
                        d = bsxfun(@times, v, model.receptive_weight);
                        s = squeeze(mean(d, [1, 2, 3]));
                        
                        % save data
                        fname = sprintf('z_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig_long, sig_short, ds, roi);
                        save(fullfile(save_address, fname), 'Z_mean');
                        fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig_long, sig_short, ds, roi);
                        save(fullfile(save_address, fname), 's');
                    end
                end
                
            case 's'
                
                % get the data
                BOLD_ben = nan(nW, N);
                BOLD_hat = nan(nW, nS, N);
                for i = 1:length(w_Lst)
                    
                    w = w_Lst(i);
                    fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                        w, 0.85, 0.1, ds, roi);
                    load(fullfile(save_address, fname), 's');
                    s_scale = s ./ s(1);
                    BOLD_ben(i, :) = s_scale;
                    
                    for j = 1:length(sig_Lst)
                        
                        sig = sig_Lst(j);
                        fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig, .1, ds, roi);
                        load(fullfile(save_address, fname), 's');
                        s_scale = s ./ s(1);
                        BOLD_hat(i, j, :) = s_scale;
                        
                    end
                end
                disp('return scaled simulation and benchmark for')
                disp('   w in')
                disp(w_Lst)
                disp('   sigma in')
                disp(sig_Lst)
                a1 = BOLD_hat;
                a2 = BOLD_ben;
                
        end
        
    case 'Elipse-nonTune'
        
        switch Data_typ
            
            case  'Filters'
                
                % some values
                sig_Lst = [.2, .85];
                
                % create OTS filters
                for i=1:length(sig_Lst)
                    
                    % equate the long and the short side
                    sig_long  = sig_Lst(i);
                    sig_short = .1;
                    sig_dot   = .01;
                    sz = round(size(E, 1)/20)*2;
                    F = kernel_weight(sig_long, sig_short, sig_dot, sz);
                    
                    % visualize the filters
                    figure();
                    for j = 1:8
                        subplot(1, 8, j)
                        imshow(F(:,:,j,j), [])
                    end
                    sgtitle(sprintf('sig_L=%02g, sig_S=%02g', sig_long, sig_short))
                end
                
            case 'Get data'
                
                % save E mean
                E_mean = squeeze(mean(E, [1,2,3,4]));
                fname = sprintf('E_mean-ds%02d-roi%02d.mat', ds, roi);
                save(fullfile(save_address, fname), 'E_mean');
                
                % some values
                sz = size(E);
                labelVec = 1:sz(end);
                model = oriSurroundModel('fmincon', 1);
                model = model.disk_weight(model, size(E, 1));
                
                % create OTS filters
                for i = 1:length(sig_Lst)
                    
                    % equate the long and the short side
                    sig_long  = sig_Lst(i);
                    sig_short = .1;
                    sig_dot   = .01;
                    Z = cal_Z_nonTune(E, labelVec, sig_long, sig_short, sig_dot);
                    
                    % try different w
                    for j = 1:length(w_Lst)
                        
                        % get w
                        w = w_Lst(j);
                        
                        % calculate the normalized energy d
                        % E_xy: [x, y, theta, ep, stim]
                        Z_mean = squeeze(mean(Z, [1,2,3,4]));
                        d = E ./ (1 + w*Z);
                        v = squeeze(mean(d, 3));
                        d = bsxfun(@times, v, model.receptive_weight);
                        s = squeeze(mean(d, [1, 2, 3]));
                        
                        % save data
                        fname = sprintf('zN_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig_long, sig_short, ds, roi);
                        save(fullfile(save_address, fname), 'Z_mean');
                        fname = sprintf('sN_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig_long, sig_short, ds, roi);
                        save(fullfile(save_address, fname), 's');
                    end
                end
                
                
            case 's'
                
                % get the data
                BOLD_ben = nan(nW, N);
                BOLD_hat = nan(nW, nS, N);
                for i = 1:length(w_Lst)
                    
                    w = w_Lst(i);
                    fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                        w, 0.85, 0.1, ds, roi);
                    load(fullfile(save_address, fname), 's');
                    s_scale = s ./ s(1);
                    BOLD_ben(i, :) = s_scale;
                    
                    for j = 1:length(sig_Lst)
                        
                        sig = sig_Lst(j);
                        fname = sprintf('sN_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                            w, sig, .1, ds, roi);
                        load(fullfile(save_address, fname), 's');
                        s_scale = s ./ s(1);
                        BOLD_hat(i, j, :) = s_scale;
                        
                    end
                end
                disp('return scaled simulation and benchmark for')
                disp('   w in')
                disp(w_Lst)
                disp('   sigma in')
                disp(sig_Lst)
                a1 = BOLD_hat;
                a2 = BOLD_ben;
                
        end
        
    case 'Norm by CE'
        
        switch Data_typ
            
            case 'get Data'
             
                model = oriSurroundModel('fmincon', 1);
                model = model.disk_weight(model, size(E, 1));
                
                % create OTS filters
                for i = 1:length(sig_Lst)
                    
                    % try different w
                    for j = 1:length(w_Lst)
                        
                        % get w
                        w = w_Lst(j);
                        
                        % calculate the normalized energy d
                        % E_xy: [x, y, theta, ep, stim]
                        d = E ./ (1 + w*E);
                        v = squeeze(mean(d, 3));
                        d = bsxfun(@times, v, model.receptive_weight);
                        s = squeeze(mean(d, [1, 2, 3]));
                        
                        % save data
                        fname = sprintf('sE_w=%02g-ds%02d-roi%02d.mat',...
                            w, ds, roi);
                        save(fullfile(save_address, fname), 's');
                    end
                end
                
             case 's'
                
                % get the data
                BOLD_ben = nan(nW, N);
                BOLD_hat = nan(nW, N);
                for i = 1:length(w_Lst)
                    
                    w = w_Lst(i);
                    fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d-roi%02d.mat',...
                        w, 0.85, 0.1, ds, roi);
                    load(fullfile(save_address, fname), 's');
                    s_scale = s ./ s(1);
                    BOLD_ben(i, :) = s_scale;
                        
                    fname = sprintf('sE_w=%02g-ds%02d-roi%02d.mat',...
                        w, ds, roi);
                    load(fullfile(save_address, fname), 's');
                    s_scale = s ./ s(1);
                    BOLD_hat(i, :) = s_scale;
                    
                end
                disp('return scaled simulation and benchmark for')
                disp('   w in')
                disp(w_Lst)
                a1 = BOLD_hat;
                a2 = BOLD_ben;
                
        end
        
        
    case 'Compare ds'
        
        w = 100;
        sz = size(E);
        labelVec = 1:sz(end);
        model = oriSurroundModel('fmincon', 1);
        model = model.disk_weight(model, size(E, 1));
        sigs = [.85, .1; .85, .85; .85, .1];
        cases = {'Elipse-oriTune', 'Round-oriTune', 'Elipse-nonTune'};
        outcomes = nan(sz(1), sz(1), 3);
        s_outcomes = nan(3);
        
        % equate the long and the short side
        figure();
        lb = 3; theta = 5;
        for i = 1:3
            
            sig_L = sigs(i, 1);
            sig_S = sigs(i, 2);
            sig_D = .01;
            Z = cal_Z(E, labelVec, sig_L, sig_S, sig_D);
            
            d = E(:, :, theta, :, lb) ./ (1 + w * Z(:, :, theta, :, lb));
            v = squeeze(mean(d, 3));
            d = bsxfun(@times, v, model.receptive_weight);
            outcomes(:, :, i) = squeeze(mean(d, [3,4,5]));
            
            d = E ./ (1 + w*Z);
            v = squeeze(mean(d, 3));
            d = bsxfun(@times, v, model.receptive_weight);
            s_outcomes(i) = mean(d(:));
            
        end
        
        for i = 1:3
            for j = 1:3
                subplot(3, 3, 3*(i-1)+j)
                imshow(outcomes(:,:,i) - outcomes(:,:,j), [])
                title(sprintf('%s \n- %s, \nthe s_{diff}=%02g',...
                    cases{i}, cases{j}, s_outcomes(i)-s_outcomes(j)));
            end
        end
        
end

end



function Z = cal_Z_nonTune(E_xy, labelVec, sig_long, sig_short, sig_dot)
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
            
            % choose the appropriate kernerl_weight and e_1 contrast energy image
            kernel_w_2D = squeeze(F(:, :, theta1, theta1)); % xy
            image_theta = squeeze(E_im(:, :, theta1)); % xy
            
            % do the convolution to combine weight and e_1 contrast energy image
            z_theta = conv2(image_theta, kernel_w_2D, 'same'); % xy . xy = xy
            
            % Assign the result into Z
            Z(:, :, theta1, ep, label) = z_theta; %Z: xyθ
        end
    end
end
fprintf('\n');
end
