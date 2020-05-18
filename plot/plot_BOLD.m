function legend_list = plot_BOLD(all_prediction, BOLD_target, dataset, roi, target )

if (nargin < 5), target = 'all'; end

% Input 1: which datasets: dataset 1 or 2...
% Input 2: which roi area: 'v1' or 'v2' ...
% input 3: the prediction of the model: a matrix: num_stim x num_models
% Input 4: legend name:
% Input 5: This is prepared for arbitrary input: like two class

% print useful information
%disp(dataset);
%disp(legend_name);

% some hyper parameters:
% colors for each model, we may want to change this in the future
dark = [52, 73, 94]./255;
blue = [52, 152, 219]./255;
red = [231, 76, 60]./255;
yellow = [ 241, 196, 15]./255;
green = [46, 204, 113]./255;
col_vector = {dark, red, blue, yellow, green};
legend_name = { 'BOLD', 'contrast', 'normVar', 'SOC', 'oriSurround' };
fontsize = 10;
linewidth = 1.5;
plotwidth = 1.5;
markersize = 4.5;
set (gca, 'FontSize', fontsize, 'LineWidth', linewidth); hold on;

nummodels = size( all_prediction ,2);

% Load the fit target: fMRI data voxel mean
if strcmp( target, 'target' )==0
    % load data
    v_mean = BOLD_target; %matrix: num_roi x num_stim
    
    % obtain some useful parameters from the data
    
    
    
    switch dataset
        case 1
            xgroups = [1 6; 7 12; 13 18; 19 25; 26 29; 30 33; 34 37; 38 42; ...
                43 47; 48 52; 53 57; 58 62];
            groupnames = {'Patterns-Sparsity','Gratings-Sparsity',...
                'NoiseBars-Sparsity','Waves-Sparisity',...
                'Grating-Orientation','Noisebar-Orientation',...
                'Waves-Orientation','Grating-cross','Grating-Contrast',...
                'Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'};
            
            all_prediction_prime  = nan( size(all_prediction, 2), 62)';
            v_mean_prime = nan( 1, 62 );
            stim_vector = [ 1:62];
            
        case 2
            xgroups = [1 6; 7 12; 13 18; 19 23; 24 27; 28 31; 32 35; 36 40; ...
                41 45; 46 50; 51 55; 56 60];
            groupnames = {'Patterns-Sparsity','Gratings-Sparsity',...
                'NoiseBars-Sparsity','Waves-Sparisity',...
                'Gratings-Orientation','Noisebars-Orientation',...
                'Wave-Orientation','Grating-cross','Grating-Contrast',...
                'Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'};
            
            all_prediction_prime  = nan( size(all_prediction, 2), 60)';
            v_mean_prime = nan( 1, 60 );
            stim_vector = [ 1:60];
            
        case {3, 4, 5}
            xgroups = [1 9; 10 14; 15 19; 20 24; 25 35; 36 41; 42 46];
            groupnames = {'Gratings-Orientation','Gratings-Contrast',...
                'Chess-Contrast','Dust-Contrast','Patterns-Contrast', ...
                'Gratings-Sparsity(-)','Patterns-Sparsity(-)'};
            
            all_prediction_prime  = nan( size(all_prediction, 2), 46)';
            v_mean_prime = nan( 1, 46 );
            stim_vector = [ 1:46];
    end
       
    count = 0;
    for i = 1:size( xgroups, 1)
        count = count + 1;
        start_idx = xgroups(i, 1);
        end_idx = xgroups(i, 2);
        all_prediction_prime( start_idx : end_idx-1, :) = all_prediction( start_idx-count+1: end_idx-count, :);
        all_prediction_prime( end_idx, :) = 0;
        v_mean_prime( 1, start_idx : end_idx-1) = v_mean(1, start_idx-count+1:end_idx-count);
        v_mean_prime( end_idx) = nan;
    end
    
    all_prediction = all_prediction_prime;
    v_mean = v_mean_prime;
    
    bar1 = bar(stim_vector, v_mean);
    set(bar1,'Facecolor', [.7, .7, .7], 'EdgeColor', [.7, .7, .7])
    
    hold on
    
    % plot for legend
    for which_prediction = 1:nummodels
        col = col_vector{which_prediction};
        %function plot_legend( )
        plot( 1:2,[nan, nan], '-o', 'MarkerSize', markersize,...
                                                                              'MarkerEdgeColor', col, ...
                                                                              'MarkerFaceColor', col,...
                                                                              'LineWidth', plotwidth,...
                                                                               'Color', col);
    end
    
    if ~isnan( all_prediction )
        
        % visualized the prediction: scatter
        for which_prediction = 1:nummodels
            model_prediction = all_prediction(: , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            for ii = 1:size(xgroups,1)
                idx = xgroups(ii,1):xgroups(ii,2)-1;
                plot(idx, model_prediction(idx), '-o', 'MarkerSize', markersize,...
                    'MarkerEdgeColor', col, ...
                    'MarkerFaceColor', col,...
                    'LineWidth', plotwidth,...
                    'Color', col);
            end
        end
    end
    
    yvalue = min( 0, min( v_mean )) - .05;
    % Label the group
    set( gca, 'xtick', xgroups(:,1));
    set( gca, 'XTickLabel', groupnames);
    xt = get( gca, 'xtick' );
    xtb = get( gca, 'XTickLabel' );
    xtextp = xt;
    ytextp=(yvalue -.05)*ones(1,length(xt));
    text(xtextp, ytextp, xtb, 'HorizontalAlignment', 'right', 'rotation', 30, 'fontsize', fontsize);
    set(gca, 'xticklabel', '')
    ylim( [yvalue, inf])
    box off
    
    if ~isnan( all_prediction )
        legend(legend_name(1:nummodels+1), 'Location', 'EastOutside')
    end
    
    hold off
    
elseif strcmp( target, 'target' )
    switch dataset
        case { 1 , 2 }
            x1 = 1:5;  y1 = 1:5;
            x2 = 7:11; y2 = 6:10;
        case { 3 , 4, 5 }
            x1 = 1:4; y1 = 9:-1:6;
            x2 = 6:10; y2 = 5:-1:1;
    end
    
    legend_list = cell( 1, nummodels );
    b1 = bar(x1, BOLD_target(y1)); hold on
    b2 = bar(x2, BOLD_target(y2));
    %     set(b1,'Facecolor', [86 44 136]/255,'Edgecolor', [86 44 136]/255);% [.7, .7, .7])
    %     set(b2,'Facecolor', [66 140 203]/255,'Edgecolor', [66 140 203]/255);% [.7, .7, .7])
    set(b1,'Facecolor', [ .6, .6, .6],'Edgecolor', [.6, .6, .6]);% [.7, .7, .7])
    %set(b2,'Facecolor', [ 1, 1,  1],'Edgecolor', [ 0, 0, 0]);% [.7, .7, .7])
    set(b2,'Facecolor', [ .8, .8, .8],'Edgecolor', [ .8, .8, .8]);% [.7, .7, .7])
    hold on
    for which_prediction = 1:nummodels
        model_prediction = all_prediction(  : , which_prediction );
        model_prediction = model_prediction';
        col = col_vector{which_prediction};
        plot(x1, model_prediction(y1), '-o', 'MarkerSize', markersize,...
            'MarkerEdgeColor', col, ...
            'MarkerFaceColor', col,...
            'LineWidth', plotwidth,...
            'Color', col);
        plot(x2, model_prediction(y2), '-o', 'MarkerSize', markersize,...
            'MarkerEdgeColor', col, ...
            'MarkerFaceColor', col,...
            'LineWidth', plotwidth,...
            'Color', col);
    end
       
    yvalue = min( 0, min( BOLD_target )) - .05;
    % Label the group
    set(gca,'xtick',[mean(x1), mean(x2)]);
    set(gca,'XTickLabel',{'Patterns-Sparsity','Gratings-Sparsity'});
    ylim( [yvalue, inf])
    box off
    
end


end
