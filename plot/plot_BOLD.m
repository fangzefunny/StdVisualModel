function legend_list = plot_BOLD(all_prediction, BOLD_target, dataset, roi, target, model_ind, error_bar)

if (nargin < 7), error_bar = nan; end

% Input 1: which datasets: dataset 1 or 2...
% Input 2: which roi area: 'v1' or 'v2' ...
% input 3: the prediction of the model: a matrix: num_stim x num_models
% Input 4: legend name:
% Input 5: This is prepared for arbitrary input: like two class

% some hyperparameters;
dark = [52, 73, 94]./255;
blue = [52, 152, 219]./255;
red = [231, 76, 60]./255;
yellow = [ 241, 196, 15]./255;
green = [46, 204, 113]./255;
col_vector = {dark, green, red, blue, yellow};
col_vector = col_vector(model_ind);
curvy = [ .4, .4, .4] + .1; grating = [ .6, .6, .6] + .1; other = [ .8, .8, .8] + .1;
legend_name = { 'BOLD', 'contrast', 'SOC', 'oriSurround', 'normVar' };
legend_name = legend_name(model_ind);
fontsize = 12;
linewidth = 1.2;
plotwidth = 1.5;
markersize = 4.5;
set (gca, 'FontSize', fontsize, 'LineWidth', linewidth); hold on;

num_models = size( all_prediction ,2);
num_stim = size( all_prediction, 1);

% Load the fit target: fMRI data voxel mean
if ~strcmp( target, 'target' )
    % load data
    BOLD = BOLD_target; %matrix: num_roi x num_stim
    % data stimuli label 
    % read the table for index information
    T = readtable( fullfile(stdnormRootPath, 'Tables/tableS2.csv'));
    % get the ind given specific dataset: question how to do exist
    ind = find(strcmp(T.Dataset,sprintf('DS%d',dataset)));
    N = length(ind);
    plt_N = num_stim + N - 1;

    % create array of the image according to the table
    pred_groups = nan(plt_N, num_models);
    curve_groups = [];
    grating_groups = [];
    pat_groups  = cell(plt_N, 1);
    var_groups  = cell(plt_N, 1);
    counter = 1;
    for i = 1:N
        % cell2mat 
        stim_ind = str2num( T.Number{i});
        ns = length(stim_ind);
        new_ind = counter:counter+ns-1;
        pred_groups(counter:counter+ns-1, :) = all_prediction(stim_num, :);
        pat = T.Patten{i};
        if strcmp( pat, 'CURVES')
            curve_groups = [ curve_groups, new_ind]; 
        elseif strcmp( pat, 'GRATINGS')
            grating_groups = [ grating_groups, new_ind];
        end
        pat_groups{i} = pat;
        var_groups{i} = T.Variation{i};
        counter = counter + ns; 
    end
    other_group = setdiff( 1:plt_N, curvy_group);
    other_group = setdiff( other_group, grating_group);
  
    %interval = [.05, .16];
    vmax = 1.6;
    count = 0;
 
   
    all_prediction = all_prediction_prime;
    v_mean = v_mean_prime;
    error_bar = error_prime;
    
    
    % plot for legend
    bar( 1:2,[nan, nan],  'Facecolor', other, 'EdgeColor', other);
    
    for which_prediction = 1:nummodels
        col = col_vector{which_prediction};
        %function plot_legend( )
        plot( 1:2,[nan, nan], '-o', 'MarkerSize', markersize,...
            'MarkerEdgeColor', col, ...
            'MarkerFaceColor', col,...
            'LineWidth', plotwidth,...
            'Color', col);
    end
    
    % plot the BOLD signal
    bar1 = bar( curvy_group, v_mean( curvy_group), 'Facecolor', curvy, 'EdgeColor', curvy);
    bar2 = bar( grating_group, v_mean( grating_group), 'Facecolor', grating, 'EdgeColor', grating);
    bar3 = bar( other_group, v_mean( other_group), 'Facecolor', other + .05, 'EdgeColor', other - .2);
    
    hold on
    
    if length(error_bar)~=1
        bar1_error = errorbar( stim_vector, v_mean, error_bar, error_bar);
        bar1_error.LineStyle = 'none';
        bar1_error.Color = [ .5, .5, .5];
    end
    
    % visualized the prediction: scatter
    for which_prediction = 1:nummodels
        model_prediction = all_prediction(: , which_prediction );
        
        if ~isnan( model_prediction )
            
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            for ii = 1:size(xgroups,1)
                lenint = ogroups( ii, 2) - ogroups( ii, 1)-1;
                idx = xgroups(ii,1):(xgroups(ii,1) + lenint);
                plot(idx, model_prediction(idx), '-o', 'MarkerSize', markersize,...
                    'MarkerEdgeColor', col, ...
                    'MarkerFaceColor', col,...
                    'LineWidth', plotwidth,...
                    'Color', col);
            end
        end
    end
    
    yvalue = min( 0, min( v_mean )) ;
%     % Label the group
%     set( gca, 'xtick', ''));
     set( gca, 'XTickLabel', '');
%     xt = get( gca, 'xtick' );
%     xtb = get( gca, 'XTickLabel' );
%     xtb2 = groupnames2;
%     xtextp = xt+3;
%     ytextp=(yvalue - interval(1))*ones(1,length(xt));
%     ytextp2 = (yvalue - interval(2)) * ones( 1, length( xt));
%     text(xtextp, ytextp, xtb, 'HorizontalAlignment', 'right', 'fontsize', fontsize);
%     text(xtextp, ytextp2, xtb2, 'HorizontalAlignment', 'right', 'fontsize', fontsize);
%     set(gca, 'xticklabel', '')
    ylim( [yvalue, vmax])
    box off
    
    %if ~isnan( all_prediction )
    %legend(legend_name(1:nummodels+1), 'Location', 'EastOutside')
    %end
    
    hold off
    
elseif strcmp( target, 'target' )
    switch dataset
        case { 1, 2}
            y1 = 1:5;  y2 = 6:10; y3 = 15:18; y4 = 11:14;
            x1 = 1:5;  x2 = 7:11;  x3 = 13:16; x4 = 18:21;
        case { 3 , 4}
            y1 = 17:-1:14; y2 = 13:-1:9; y3 = 5:8;  y4 = 1:4;
            x1 = 1:4; x2 = 6:10; x3 = 12:15; x4 = 17:20;
    end
    
    legend_list = cell( 1, nummodels );
    
    b1 = bar(x1, BOLD_target(y1)); hold on
    b2 = bar(x2, BOLD_target(y2));
    b3 = bar(x3, BOLD_target(y3));
    b4 = bar(x4, BOLD_target(y4));
    if length(error_bar)~=1
        b1_error = errorbar( x1, BOLD_target(y1), error_bar(y1), error_bar(y1));
        b2_error = errorbar( x2, BOLD_target(y2), error_bar(y2), error_bar(y2));
        b3_error = errorbar( x3, BOLD_target(y3), error_bar(y3), error_bar(y3));
        b4_error = errorbar( x4, BOLD_target(y4), error_bar(y4), error_bar(y4));
        
    end
    
    set(b1,'Facecolor', curvy,'Edgecolor', curvy);% [.7, .7, .7])
    set(b2,'Facecolor', grating,'Edgecolor', grating);% [.7, .7, .7])
    set(b3,'Facecolor', curvy,'Edgecolor', curvy);% [.7, .7, .7])
    set(b4,'Facecolor', grating,'Edgecolor', grating);% [.7, .7, .7])
    
    if length(error_bar)~=1
        set(b1_error,'LineStyle', 'none','Color', .2*[1 1 1]);% [.7, .7, .7])
        set(b2_error,'LineStyle', 'none','Color', .2*[1 1 1]);% [.7, .7, .7])
        set(b3_error,'LineStyle', 'none','Color', .2*[1 1 1]);% [.7, .7, .7])
        set(b4_error,'LineStyle', 'none','Color', .2*[1 1 1]);% [.7, .7, .7])
    end
    
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
        plot(x3, model_prediction(y3), '-o', 'MarkerSize', markersize,...
            'MarkerEdgeColor', col, ...
            'MarkerFaceColor', col,...
            'LineWidth', plotwidth,...
            'Color', col);
        plot(x4, model_prediction(y4), '-o', 'MarkerSize', markersize,...
            'MarkerEdgeColor', col, ...
            'MarkerFaceColor', col,...
            'LineWidth', plotwidth,...
            'Color', col);
    end
    
     yvalue = min( 0, min( BOLD_target )) - .05;
%     interval = max(BOLD_target) * .2;
%     % Label the group
%     xt = [mean(x1)+1.3, mean(x2)+1.5, mean(x3)+2.2, mean(x4)+2.7];
%     set(gca,'xtick',[mean(x1), mean(x2), mean(x3), mean(x4)+.5]);
%     set(gca,'XTickLabel',{'Patterns-','Gratings-', 'Pattens-', 'Gratings-'});
%     ytextp2 = (yvalue - interval) * ones( 1, length( xt));
%     xtb = { 'Density','Density', 'Contrast', 'Contrast'};
%     text(xt, ytextp2, xtb, 'HorizontalAlignment', 'right', 'fontsize', fontsize);
    ylim( [yvalue, inf])
    box off
    
end


end
