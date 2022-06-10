function OTSFilters(fig_idx, ds, roi)
%{
    Investigate different normalization fitlers

    Args:
        fig_idx -'Circle-oriTune': circle filters that are orientation
                    tuned
                -'Elipse-nonTune': elipse filters that are not orientation
                    tuned
                -'Elipse-oriTune': 
        ds: data set
        roi: visual cortex. 1, 2, 3
%}
% get the default value
if (nargin < 3), roi = 1; end
if (nargin < 2), ds = 1; end

% save_dir
save_address = fullfile(stdnormRootPath, 'analyses', 'data');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% make w list
w_Lst    = [.1, 1, 10, 100, 10000, 1e6];
curvy   = [  .4,  .4,  .4] + .1;
grating = [  .6,  .6,  .6] + .1;

switch fig_idx

    case 'Circle-oriTune Filters'

        % load E
        E = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        sig_Lst = [.2, .9];

        % create OTS filters
        for i=1:length(sig_Lst)

            % equate the long and the short side
            sig_long  = sig_Lst(i);
            sig_short = sig_Lst(i);
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
        end

    case 'Elipse-oriTune Filters'

        % load E
        E = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        sig_Lst = [.2, .9];

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
        end

    case 'Elipse-nonTune Filters'

        % load E
        E = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        sig_Lst = [.2, .9];

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
        end

    case 'Circle-oriTune GetEnergy'

        % load E
        E_xy = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        sz = size(E_xy);
        labelVec = 1:sz(end);
        model = oriSurroundModel('fmincon', 1);
        model = model.disk_weight(model, size(E_xy, 1));

        % get the grid search value
        sig_Lst  = linspace(.1, .85, 5);

        % create OTS filters
        for i = 1:length(sig_Lst)

            % equate the long and the short side
            sig_long  = sig_Lst(i);
            sig_short = sig_Lst(i);
            sig_dot   = .01;
            Z = cal_Z(E_xy, labelVec, sig_long, sig_short, sig_dot);

            % try different w
            for j = 1:length(w_Lst)

                % get w
                w = w_Lst(j);

                % calculate the normalized energy d
                % E_xy: [x, y, theta, ep, stim]
                z = squeeze(mean(Z, [1,2,3,4]));
                d = E_xy ./ (1 + w * Z);
                v = squeeze(mean(d, 3));
                d = bsxfun(@times, v, model.receptive_weight);
                s = squeeze(mean(d, [1, 2, 3]));

                % save data
                fname = sprintf('z_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig_long, sig_short, ds);
                save(fullfile(save_address, fname), 'z');
                fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig_long, sig_short, ds);
                save(fullfile(save_address, fname), 's');
            end
        end

    case 'Elipse-oriTune GetEnergy'

        % load E
        E_xy = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        sz = size(E_xy);
        labelVec = 1:sz(end);
        model = oriSurroundModel('fmincon', 1);
        model = model.disk_weight(model, size(E_xy, 1));

        % get the grid search value
        sig_l_Lst  = linspace(.1, .85, 5);

        % create OTS filters
        for i = 1:length(sig_l_Lst)

            % equate the long and the short side
            sig_long  = sig_l_Lst(i);
            sig_short = .1;
            sig_dot   = .01;
            Z = cal_Z(E_xy, labelVec, sig_long, sig_short, sig_dot);

            % try different w
            for j = 1:length(w_Lst)

                % get w
                w = 100;%w_Lst(j);

                % calculate the normalized energy d
                % E_xy: [x, y, theta, ep, stim]
                z = squeeze(mean(Z, [1,2,3,4]));
                d = E_xy ./ (1 + w * Z);
                v = squeeze(mean(d, 3));
                d = bsxfun(@times, v, model.receptive_weight);
                s = squeeze(mean(d, [1, 2, 3]));

                % save data
                fname = sprintf('z_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig_long, sig_short, ds);
                save(fullfile(save_address, fname), 'z');
                fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig_long, sig_short, ds);
                save(fullfile(save_address, fname), 's');
            end
        end

    case 'Elipse-nonTune GetEnergy'

        % load E
        E_xy = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        sz = size(E_xy);
        labelVec = 1:sz(end);
        model = oriSurroundModel('fmincon', 1);
        model = model.disk_weight(model, size(E_xy, 1));

        % get the grid search value
        sig_l_Lst  = linspace(.1, .85, 5);

        % create OTS filters
        for i = 1:length(sig_l_Lst)

            % equate the long and the short side
            sig_long  = sig_l_Lst(i);
            sig_short = .1;
            sig_dot   = .01;
            Z = cal_Z_nonTune(E_xy, labelVec, sig_long, sig_short, sig_dot);

            % try different w
            for j = 1:length(w_Lst)

                % get w
                w = w_Lst(j);

                % calculate the normalized energy d
                % E_xy: [x, y, theta, ep, stim]
                z = squeeze(mean(Z, [1,2,3,4]));
                d = E_xy ./ (1 + w * Z);
                v = squeeze(mean(d, 3));
                d = bsxfun(@times, v, model.receptive_weight);
                s = squeeze(mean(d, [1, 2, 3]));

                % save data
                fname = sprintf('zN_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig_long, sig_short, ds);
                save(fullfile(save_address, fname), 'z');
                fname = sprintf('sN_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig_long, sig_short, ds);
                save(fullfile(save_address, fname), 's');
            end
        end

    case 'E GetEnergy'

        % load E
        E_xy = dataloader(stdnormRootPath, 'E_xy',...
            'target', ds, roi);

        % some values
        model = oriSurroundModel('fmincon', 1);
        model = model.disk_weight(model, size(E_xy, 1));

        % get the grid search value
        sig_l_Lst  = linspace(.1, .85, 5);

        % create OTS filters
        for i = 1:length(sig_l_Lst)

            % equate the long and the short side
            Z = E_xy;

            % try different w
            for j = 1:length(w_Lst)

                % get w
                w = w_Lst(j);

                % calculate the normalized energy d
                % E_xy: [x, y, theta, ep, stim]
                z = squeeze(mean(Z, [1,2,3,4]));
                d = E_xy ./ (1 + w * Z);
                v = squeeze(mean(d, 3));
                d = bsxfun(@times, v, model.receptive_weight);
                s = squeeze(mean(d, [1, 2, 3]));

                % save data
                fname = sprintf('zE_w=%02g-ds%02d-roi%02d.mat',...
                    w, ds, roi);
                save(fullfile(save_address, fname), 'z');
                fname = sprintf('sE_w=%02g-ds%02d-roi%02d.mat',...
                    w, ds, roi);
                save(fullfile(save_address, fname), 's');
            end
        end

    case 'compare'

        % get targe & index
        BOLD_tar = dataloader(stdnormRootPath, 'BOLD_target',...
            'target', ds, roi);
        switch ds
            case 1; tar_ind = [1:5;6:10;15,16,3,17,18;11,12,8,13,14]; N=18;
            case 4; tar_ind = [9:12, 26, 28:39];
        end


        % Visualize the circle-tuned

        % get the parameter
        sig_Lst  = linspace(.1, .85, 5);
        nW = length(w_Lst);
        nS = length(sig_Lst);
        viz = ColorPalette();
        colors = {curvy, grating, curvy, grating};

        % get the data
        BOLD_hat1 = nan(nW, N);
        BOLD_hat2 = nan(nW, nS, N);
        for i = 1:length(w_Lst)

            w = w_Lst(i);
            fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                w, 0.85, 0.1, ds);
            load(fullfile(save_address, fname), 's');
            s_scale = s ./ s(1);
            BOLD_hat1(i, :) = s_scale;

            for j = 1:length(sig_Lst)

                sig = sig_Lst(j);
                fname = sprintf('s_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                    w, sig, sig, ds);
                load(fullfile(save_address, fname), 's');
                s_scale = s ./ s(1);
                BOLD_hat2(i, j, :) = s_scale;

            end
        end

        % visualize the comparison
        for i = 1:length(w_Lst)
            for j = 1:length(sig_Lst)
                subplot(nW, nS, (i-1)*nS+j)
                hold on
                for k = 1:size(tar_ind, 1)
                    ind = tar_ind(k, :);
                    bar(6*k-5:6*k-1, BOLD_tar(ind)./BOLD_tar(1),...
                        'Facecolor', colors{k},...
                        'EdgeColor', colors{k});
                    plot(6*k-5:6*k-1, squeeze(BOLD_hat1(i, ind)),...
                        '-o', 'MarkerSize', 5,...
                        'MarkerEdgeColor', viz.Red, ...
                        'MarkerFaceColor', viz.Red,...
                        'LineWidth', 3,...
                        'Color', viz.Red);
                    plot(6*k-5:6*k-1, squeeze(BOLD_hat2(i, j, ind)),...
                        '-o', 'MarkerSize', 5,...
                        'MarkerEdgeColor', viz.Blue, ...
                        'MarkerFaceColor', viz.Blue,...
                        'LineWidth', 3,...
                        'Color', viz.Blue);
                end
            end
        end
        hold off

    case 'compare E'

        % get targe & index
        BOLD_tar = dataloader(stdnormRootPath, 'BOLD_target',...
            'target', ds, roi);
        switch ds
            case 1; tar_ind = [1:5;6:10;15,16,3,17,18;11,12,8,13,14]; N=18;
            case 4; tar_ind = [9:12, 26, 28:39];
        end


        % Visualize the circle-tuned

        % get the parameter
        sig_Lst  = linspace(.1, .85, 5);
        nW = length(w_Lst);
        nS = length(sig_Lst);
        viz = ColorPalette();
        colors = {curvy, grating, curvy, grating};

        % get the data
        BOLD_hat1 = nan(nW, N);
        BOLD_hat2 = nan(nW, N);
        for i = 1:length(w_Lst)

            w = w_Lst(i);
            fname = sprintf('z_w=%02g-sig_l=%02g-sig_s=%02g-ds%02d.mat',...
                w, 0.85, 0.1, ds);
            load(fullfile(save_address, fname), 'z');
            s_scale = z ./ z(1);
            BOLD_hat1(i, :) = s_scale;

            fname = sprintf('zE_w=%02g-ds%02d-roi%02d.mat',...
                w, ds, roi);
            load(fullfile(save_address, fname), 'z');
            s_scale = z ./ z(1);
            BOLD_hat2(i, :) = s_scale;
        end

        % visualize the comparison
        for i = 1:length(w_Lst)
            subplot(1, nW, i)
            hold on
            for k = 1:size(tar_ind, 1)
                ind = tar_ind(k, :);
                bar(6*k-5:6*k-1, BOLD_tar(ind)./BOLD_tar(1),...
                    'Facecolor', colors{k},...
                    'EdgeColor', colors{k});
                plot(6*k-5:6*k-1, squeeze(BOLD_hat1(i, ind)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', viz.Red, ...
                    'MarkerFaceColor', viz.Red,...
                    'LineWidth', 3,...
                    'Color', viz.Red);
                plot(6*k-5:6*k-1, squeeze(BOLD_hat2(i, ind)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', viz.Blue, ...
                    'MarkerFaceColor', viz.Blue,...
                    'LineWidth', 3,...
                    'Color', viz.Blue);
            end
        end
        hold off
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
