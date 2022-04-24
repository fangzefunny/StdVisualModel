
function [] = s4_visualize(fig, plotData)
%{
    A function used to generate figures in the paper.
    Replace the fig with any figure index (as str) you see in the paper.
    Please do not include space in the str.
    for example, to obtain figure 1, fig = 'figure1'
    although... we do not have figure 1...
%}

if ~exist('plotData', 'var') || isempty(plotData), plotData = true; end
if strcmp(fig, 'thumbnails')
    
    set(0,'DefaultFigureVisible', 'off')
    set (gcf,'Position',[0,0,512,512])
    datasets = [ 1, 2, 3, 4];
    ep = 5;
    for i = 1:length(datasets)
        folder = sprintf('dataset%02d', datasets(i));
        save_address = fullfile(stdnormRootPath, 'thumbnails', folder);
        if ~exist(save_address, 'dir'), mkdir(save_address); end
        stim = dataloader(stdnormRootPath, 'stimuli', 'all', datasets(i));
        for j = 1: size(stim, 4)
            imshow(stim(:, :, ep, j), [], 'border', 'tight', 'initialmagnification','fit')
            fname = fullfile(save_address, sprintf('%d.png', j));
            saveas(gcf, fname)
        end
    end
end

if strcmp(fig,'figure2')
    
    nTheta  = 8;
    sigma_p = .1;
    sigma_g = .85;
    sigma_s = .01;
    sz      = 30;
    kernel_w = kernel_weight(sigma_p, sigma_g, sigma_s, sz);
    for theta1 = 1: nTheta
        for theta2 = 1:nTheta
            subplot(8, 8, (theta1-1)*nTheta + theta2)
            imshow(squeeze(kernel_w(:, :, theta1, theta2)), []);
            title(sum(kernel_w(:, :, theta1, theta2),[1,2]))
            axis off
        end
    end
    
  
elseif strcmp(fig, 'checkOTS')
    
    % Some variables
    dataset  = 1;
    labelVec = 1:50;
    roi      = 1;
    ep       = 5;
    snake    = [ .4, .4, .4] + .1;
    grating  = [ .6, .6, .6] + .1;
    colors   = { grating, snake};
    
    % Parameters
    w        = 680;
    g        = 1;
    n        = 1;
    
    % Get model prediction
    % get stimulus: S
    % x x y x exp x stim --> x x y x stim
    S = dataloader(stdnormRootPath, 'stimuli', 'all', dataset, roi);
    S = squeeze(S(:, :, ep, :));
    % get numerator: E
    E = dataloader(stdnormRootPath, 'E_xy', 'all', dataset, roi);
    E_viz = squeeze(mean(mean(E(:, :, :, ep, :),2),1)); % orixstim
    % get denominator: Z
    Z = cal_Z(E, labelVec);
    % get normalized energy
    % x x y x ori x exp x stim --> x x y x ori x stim
    d = E ./ (1 + w * Z); 
    v = squeeze(d(:, :, :, ep, :));
    v = g .* v .^n;
    
    % Viualization: understand the OTS using figure 10
    % x x y x ori x stim --> ori x stim
    v_viz = squeeze(mean(mean(v, 2), 1));
    % gratings-snakes vector
    stim_ind = [ 8, 3];
    for i = 1:2 
        % stim index 
        stim_idx = stim_ind(i);
        % show the stimuli 
        subplot(2, 3, (i-1)*3 + 1)
        imshow(S(:, :, stim_idx), [-.1, .1]);
        axis off
        % visualize E: contrast energy - ori 
        subplot(2, 3, (i-1)*3 + 2)
        e = E_viz(:, stim_idx);
        bar(e, 'FaceColor', colors{i},...
            'EdgeColor', colors{i});
        set(gca,'xtick',[])
        ylim([ 0, .3])
        sum_txt = sprintf('sum=%.2f', sum(e));
        text(.1, .28, sum_txt)
        var_txt = sprintf('var=%.6f', var(e));
        text(.1, .25, var_txt)
        box off
        % visualize d: normalized energy - ori 
        subplot(2, 3, (i-1)*3 + 3)
        d = v_viz(:, stim_idx);
        bar(d, 'FaceColor', colors{i},...
            'EdgeColor', colors{i});
        set(gca,'xtick',[])
        ylim([ 0, .3])
        sum_txt = sprintf('sum=%.2f', sum(d));
        text(.1, .28, sum_txt)
        box off
    end
    
elseif strcmp(fig, 'figure3.1')
    
    open('figures/Figure2E_fitSOCbbpower.fig');
    subplot(8,1,1);
    x = get(gca, 'UserData');
    close all;
    
    fontsize = 7.5;
    cur_color = ones(1,3) * .6;
    gra_color = ones(1,3) * .8;
    cur_stims = 78:-1:74;
    gra_stims = 73:-1:69;
    figure;
    fig_width = 6;
    pos = [10, 5, fig_width, .5*fig_width];
    set(gcf, 'unit', 'centimeters', 'position', pos, 'color', 'w');
    bar(1:5, x.mn(cur_stims), 'Facecolor', cur_color, 'EdgeColor', cur_color); hold on;
    e1 = errorbar(1:5, x.mn(cur_stims), x.err(cur_stims), x.err(cur_stims));
    bar(7:11, x.mn(gra_stims), 'Facecolor', gra_color, 'EdgeColor', gra_color); hold on;
    e2 = errorbar(7:11, x.mn(gra_stims), x.err(gra_stims), x.err(cur_stims));
    set(e1,'LineStyle', 'none','Color', .2*[1 1 1]);
    set(e2,'LineStyle', 'none','Color', .2*[1 1 1]);
    set(gca, 'XTickLabel', '');
    set (gca, 'FontSize', fontsize);
    box off
    
elseif strcmp(fig, 'figureS1')
    
    stim = dataloader(stdnormRootPath, 'stimuli', 'All', 4, 1);
    figure;
    set(gcf, 'color', 'w');
    for ii = 1:size(stim, 4)
        subplot(5, 10, ii)
        imshow(stim(:, :, 1, ii), []);
    end
    
elseif strcmp(fig, 'figure8')
    
    % define the models and data sets
    models = { 'CE', 'SOC', 'OTS', 'NOA', 'Data'};
    data_sets = [ 1, 2, 3, 4];
    
    % get the plot color
    v3      = [ .1, .1, .1];
    v2      = [ .5, .5, .5];
    v1      = [ .8, .8, .8];
    
    % get stimuli
    T = readtable(fullfile(stdnormRootPath, 'Tables/hetero_tables.csv'));
    
    % get contrast 
    contrast_mean = NaN(3, length(models));
    contrast_sem  = NaN(3, length(models));
    for i = 1:length(models)
        snakes_mean_model   = NaN(3, 4);
        gratings_mean_model = NaN(3, 4);
        for j = 1:length(data_sets)
            idx = (i - 1) * 4 + j;
            vars_nm = T.Properties.VariableNames;
            for k = 2:length(vars_nm)
                if mod(k, 2)
                    gratings_mean_model(floor(k/2), j) = mean(T{ idx, vars_nm{k}});
                else
                    snakes_mean_model(floor(k/2), j) = mean(T{ idx, vars_nm{k}});
                end
            end
            
        end
%         contrast = (snakes_mean_model - gratings_mean_model) ...
%                     ./ ((snakes_mean_model + gratings_mean_model)/2);
        contrast = snakes_mean_model ./ gratings_mean_model; 
        contrast_mean(:, i) = mean(contrast, 2);
        contrast_sem(:, i)  = std(contrast, 0, 2) / sqrt(length(data_sets));
    end
    
    x = 1:length(models);
    b = bar(x, contrast_mean', 'BaseValue', 1);
    b(1).FaceColor  = v1;
    b(2).FaceColor  = v2;
    b(3).FaceColor  = v3;
    
    hold on
    for i = 1:3
        er = errorbar(x + (i-2)*.225, contrast_mean(i,:), contrast_sem(i,:));
        if i==3
            er.Color = [ .5, .5, .5];
        else 
            er.Color = [ 0, 0, 0];
        end
        er.LineStyle = 'none';
    end
    legend('V1', 'V2', 'V3', 'Location', 'southwest')
    xticklabels(models)
    
    ylim([ 1/3, 3])
    set(gca, 'Yscale', 'log', 'Fontsize', 15, 'YTick', [ 1/3, 1/2, 1, 2, 3],...
         'YTickLabel', { '1/3', '1/2', '1', '2', '3'})
    set(gcf, 'Color', 'w')
    box off
    
elseif strcmp(fig, 'figure10')
    
    % get the plot color
    curvy = [ .4, .4, .4] + .1;
    grating = [ .6, .6, .6] + .1;
    ep = 5;
    s  = 4;
    w = 100;
    
    % get stimuli
    stim_ind = [ 8, 3, 35, 47];
    colors   = { grating, curvy, grating, curvy};
    stim = dataloader(stdnormRootPath, 'stimuli', 'all', 1, 1);
    E_ori = dataloader(stdnormRootPath, 'E_ori', 'all', 1, 1);
    stim = squeeze(stim(:, :, ep, stim_ind));
    E_ori = s * squeeze(E_ori(:, ep, stim_ind));
    
    for i = 1:length(stim_ind)
        % visualize the raw stimuli
        x = E_ori(: , i);
        d = x ./ (1 + w * var(x));
        subplot(4, 3, (i-1)*3 + 1)
        imshow(stim(:, :, i), [-.1, .1]);
        axis off
        % visualize E_ori^2
        subplot(4, 3, (i-1)*3 + 2)
        bar(x, 'FaceColor', colors{i},...
            'EdgeColor', colors{i});
        set(gca,'xtick',[])
        ylim([ 0, .3])
        sum_txt = sprintf('sum=%.2f', sum(x));
        text(.1, .28, sum_txt)
        var_txt = sprintf('var=%.6f', var(x));
        text(.1, .25, var_txt)
        box off
        % visualize d
        subplot(4, 3, (i-1)*3 + 3)
        bar(d, 'FaceColor', colors{i},...
            'EdgeColor', colors{i});
        set(gca,'xtick',[])
        ylim([ 0, .3])
        sum_txt = sprintf('sum=%.2f', sum(d));
        text(.1, .28, sum_txt)
        box off
    end
    
elseif strcmp(fig, 'figure?')
    
    % have a look at the filter
    nTheta  = 8;
    sigma_p = .1;
    sigma_g = .85;
    sigma_s = .01;
    sz      = 30;
    kernel_w = kernel_weight(sigma_p, sigma_g, sigma_s, sz);
    for theta1 = 1: nTheta
        for theta2 = 1:nTheta
            % subplot(8, 8, (theta1-1)*nTheta + theta2)
            % imshow(squeeze(kernel_w(:, :, theta1, theta2)), []);
            axis off
        end
    end
    
    % show the normalization shape
    E_xy = dataloader(stdnormRootPath, 'E_xy', 'target', 1, 1);
    
    % choose thete
    curvy   = [  .4,  .4,  .4] + .1;
    grating = [  .6,  .6,  .6] + .1;
    stims = [ 3, 8];
    for idx = 1:2
        Z = NaN(8,1);
        stim = stims(idx);
        for ep = 1
            E = squeeze(mean(mean(E_xy(:, :, :, ep, stim),2),1));
            
            Z2 = NaN(nTheta, 1);
            for theta1 = 1:nTheta
                sum_img = 0;
                F2 = squeeze(kernel_w(:, :, :, theta1));
                Ex = squeeze(E_xy(:, :, theta1, ep, stim));
                Ex = repmat(Ex, 1, 1, 8);
                
                for theta2 = 1:nTheta
                    %subplot(6, 4, theta2)
                    F = squeeze(kernel_w(:, :, theta2, theta1));
                    %imshow(F, []);
                    %subplot(6, 4, 8+theta2)
                    img = squeeze(E_xy(:, :, theta2, ep, stim));
                    %imshow(img, [0, .25])
                    %subplot(6, 4, 16+theta2)
                    c_img = conv2(img, F, 'same');
                    %imshow(c_img, [0, .1])
                    sum_img = sum_img + c_img / nTheta;
                end
                Z(theta1, 1) = mean(sum_img(:));
                
            end
        end
        subplot(1, 2, idx)
        plot(E, 'color', curvy, 'linewidth', 5)
        ylim([ 0, .01])
        hold on
        plot(Z, 'color', grating, 'linewidth', 5)
        legend('E_{ori}', 'Z')
        ylim([ 0, .1])
        box off
        
    end
    
    
else
    
    % Tune the hyperparameters
    doModel          = true;
    optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
    error_bar        = true;
    data_folder      = 'Cross';  % save in which folder. value space: 'noCross', .....
    target           = 'target';
    switch fig
        
        case {'figure3'}
            doModel  = false;
        case {
                'figure9'  ,...
                'figureS3a', 'figureS3b', 'figureS3c',...
                'figureS4a', 'figureS4b', 'figureS4c', 'figureS4d',...
                'figureS5a', 'figureS5b', 'figureS5c', 'figureS5d',...
                'figureS6a', 'figureS6b', 'figureS6c', 'figureS6d',...
                'figureS7a', 'figureS7b', 'figureS7c', 'figureS7d',...
                }
            target   = 'all';
    end
    
    % Generate save address and  choose data
    figure_address = fullfile(stdnormRootPath, 'figures', data_folder, target, optimizer);
    if ~exist(figure_address, 'dir'), mkdir(figure_address); end
    
    % Choose data as if we are doing parallel computing
    T = chooseData(fig, optimizer, 40);
    model_ind = sort(unique(T.modelNum))';
    
    %% Load data
    
    % Init the data storages
    numstimuli            = 50;
    all_datasets          = unique(T.dataset);
    nummodels             = length(unique(T.modelNum));
    numrois               = length(unique(T.roiNum));
    numdatasets           = length(unique(T.dataset));
    pred_summary_all      = NaN(numstimuli,nummodels,numdatasets, numrois);
    targ_pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
    data_summary_all      = NaN(numstimuli,1,numdatasets, numrois);
    err_summary_all       = NaN(numstimuli,1,numdatasets, numrois);
    num_stimuli           = NaN(numdatasets,1);
    
    % Loop through datasets and load model predictions and data
    for data_idx = 1:numdatasets
        
        % select data set
        dataset = all_datasets(data_idx);
        
        for roi = 1:numrois
            for idx = 1:nummodels
                
                % select model
                model_idx = T.modelNum(idx);
                
                % load BOLD target
                BOLD_data = dataloader(stdnormRootPath, 'BOLD_target', 'all', dataset, roi);
                len_stim = length(BOLD_data);
                num_stimuli(data_idx) = len_stim;
                data_summary_all(1:len_stim, 1, data_idx, roi) = BOLD_data';
                
                % load errorbar
                if error_bar
                    BOLD_data_error = dataloader(stdnormRootPath, 'BOLD_target_error', 'all', dataset, roi);
                    err_summary_all(1:len_stim, 1, data_idx, roi) = BOLD_data_error';
                end
                
                % load BOLD prediction for all stimuli
                if doModel
                    target_pred = dataloader(stdnormRootPath, 'BOLD_pred', 'all', dataset, roi, data_folder, model_idx, optimizer);
                    pred_summary_all(1:len_stim, idx, data_idx, roi) = target_pred;
                end
                
                % load BOLD prediction for the target data (this is a bit tricky)
                % Because plot_BOLD is designed to generate figures using
                % the whole dataset, I load the target data set in the form of
                % full dataset, with all nan but all valued for targets.
                target_BOLD_pred = dataloader(stdnormRootPath, 'BOLD_pred', 'target', dataset, roi, data_folder, model_idx, optimizer);
                if doModel
                    switch dataset
                        case 1
                            target_ind = [ 1:10, 35:38, 47:50];
                        case 2
                            target_ind = [ 1:10, 33:36, 45:48];
                        case {3, 4}
                            target_ind = [ 9:12,    26, 28:39];
                    end
                    targ_pred_summary_all(target_ind, idx, data_idx, roi) = target_BOLD_pred';
                end
            end
        end
    end
    
    %% Make figures
    
    if strcmp(target, 'target')
        
        %%%%%%%%%%%%%%% Fig. for target data set  %%%%%%%%%%%%%%%%
        
        % Intialize a figure
        fig_width = 20;
        fig_height = 3.5 * numdatasets;
        pos = [10, 5, 2*fig_width, 2*fig_height];
        set(gcf, 'unit', 'centimeters', 'position', pos, 'color', 'w');
        subplot(numdatasets, numrois+1, numdatasets+1)
        
        % Loop through datasets and make plots
        for data_idx = 1:numdatasets
            
            dataset = all_datasets(data_idx);
            
            % for each each ori area
            for roi = 1:numrois
                % get the total length of the data
                len_stim  = num_stimuli(data_idx);
                % get the data for plots
                BOLD_data = data_summary_all(1:len_stim, 1, data_idx, roi)';
                % get the error bar for plots
                BOLD_err = err_summary_all(1:len_stim, 1, data_idx, roi)';
                % get the model prediction
                target_preds = targ_pred_summary_all(1:len_stim, :, data_idx, roi)';
                
                % subplot dataset, roi, idx
                idx = (data_idx-1)*(numrois+1) + roi;
                subplot(numdatasets, numrois+1, idx)
                plot_BOLD(target_preds, BOLD_data, BOLD_err, dataset, model_ind, target, plotData);
                
                % display title
                show_title = sprintf('V%d', roi);
                title(show_title)
                
                % add legend to specify the model's predictions
                if doModel
                    if idx ==numrois
                        subplot(numdatasets, numrois+1, idx+1)
                        plot_legend(target_preds, model_ind)
                    end
                end
            end
        end
        
    else
        %%%%%%%%%%%%%%% Fig. for whole data set  %%%%%%%%%%%%%%%%
        
        % init a figure
        fig_width  = 17;
        fig_height = 17;
        pos = [10, 5, 2*fig_width, 2*fig_height];
        set(gcf, 'unit', 'centimeters', 'position', pos, 'color', 'w');
        
        
        % Loop through datasets and make plots
        for data_idx = 1:numdatasets
            
            dataset = all_datasets(data_idx);
            
            % for each each ori area
            for roi = 1:numrois
                
                % get the total length of the data
                len_stim  = num_stimuli(data_idx);
                % get the data for plots
                BOLD_data = data_summary_all(1:len_stim, 1, data_idx, roi)';
                % get the error bar for plots
                BOLD_err  = err_summary_all(1:len_stim, 1, data_idx, roi)';
                % get the model prediction
                BOLD_preds = pred_summary_all(1:len_stim, :, data_idx, roi)';
                
                % subplot dataset, roi, idx
                subplot(numrois+1, 1, roi)
                
                % if we add model prediction
                plot_BOLD(BOLD_preds, BOLD_data, BOLD_err, dataset, model_ind, target, plotData)
                
                % display title
                show_title = sprintf('V%d', roi);
                title(show_title)
            end
            
            % add legend to specify the model's predictions
            if doModel
                subplot(numrois+1, 1, roi+1)
                plot_legend(BOLD_preds, model_ind)
            end
        end
    end
end
end

