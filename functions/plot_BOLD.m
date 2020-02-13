function plot_BOLD(dataset, roi, all_prediction, legend_name, t_mean_op)

% Input 1: which datasets: dataset 1 or 2...
% Input 2: which roi area: 'v1' or 'v2' ...
% input 3: the prediction of the model: a matrix: num_stim x num_models
% Input 4: legend name:
% Input 5: This is prepared for arbitrary input: like two class

% print useful information
disp(dataset)
disp(legend_name)

% some hyper parameters:
% colors for each model, we may want to change this in the future
col_vector = {'k', 'r', 'g', 'b', 'y', 'm'};
fontsize = 12;
linewidth = 4;
markersize = 10;
set (gca, 'FontSize', fontsize, 'LineWidth', linewidth); hold on;

% Load the fit target: fMRI data voxel mean
if isnumeric(dataset)
    % load data
    fname = sprintf('dataset%02d.mat', dataset);
    load(fname, 'v_mean');
    v_mean = v_mean(roi, : ); %matrix: num_roi x num_stim
    
    % obtain some useful parameters from the data
    numstim = size(v_mean, 2);
    
    switch dataset
        case 1
            xgroups = [1 5; 6 10; 11 15; 16 21; 22 24; 25 27; 28 30; 31 34; ...
                35 38; 39 42; 43 46; 47 50];
            groupnames = {'Patterns-Sparsity','Grating-Sparsity',...
                'NoiseBars-Sparsity','Waves-Sparisity',...
                'Grating-Orientation','Noisebar-Orientation',...
                'Waves-Orientation','Grating-cross','Grating-Contrast',...
                'Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'};
            
        case 2
            xgroups = [1 5; 6 10; 11 15; 16 19; 20 22; 23 25; 26 28; 29 32; ...
                33 36; 37 40; 41 44; 45 48];
            groupnames = {'Patterns-Sparsity','Grating-Sparsity',...
                'NoiseBars-Sparsity','Waves-Sparisity',...
                'Grating-Orientation','Noisebar-Orientation',...
                'Waves-Orientation','Grating-cross','Grating-Contrast',...
                'Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'};
            
        case {3, 4}
            xgroups = [1 8; 9 12; 13 16; 17 20; 21 30; 31 35; 36 39];
            groupnames = {'Grating-Orientation','Grating-Contrast',...
                'Chess-Contrast','Dust-Contrast','Pattern-Contrast', ...
                'Grating-Sparsity(-)','Pattern-Sparsity(-)'};
    end
    
    
    bar1 = bar(1:numstim , v_mean);
    set(bar1,'Facecolor', [.7, .7, .7],'EdgeColor',[.7, .7, .7])
    
    hold on
    
    if ~isempty(all_prediction)
        
        nummodels = size( all_prediction ,2);
        all_prediction = all_prediction(1:numstim,:); %???
        
        % visualized the prediction: scatter
        for which_prediction = 1:nummodels
            
            model_prediction = all_prediction(: , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:numstim, model_prediction, 'filled','MarkerFaceColor', col)
            
        end
        
        % visualized the prediction: line plot
        for which_prediction = 1:nummodels
            
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            for ii = 1:size(xgroups,1)
                idx = xgroups(ii,1):xgroups(ii,2);
                plot(idx, model_prediction(idx), col);
            end
        end
        
    end
    
    % seperate the group of the data and label 
    
    % Label the group
    set(gca, 'xtick', xgroups(:,1));
    set(gca, 'XTickLabel', groupnames);

    h=gca;
    th=rotateticklabel(h,45);
    box off
    hold on

    % The legend of the line
    g=max(v_mean)*1;

    for ii = 1:size(xgroups,1)
        x = xgroups(ii,2)+.4;
        line([x x],[0,g])
    end
        
    if ~isempty(legend_name)
        legend('data', legend_name, 'Location', 'EastOutside')
    end
    
else
    markersize = 10;
    switch dataset
        case { '1_target' , '2_target'}
            x1 = 1:5;  y1 = 1:5;
            x2 = 6:10; y2 = 6:10;
        case { '3_target' , '4_target'}
            x1 = 1:4; y1 = 9:-1:6;
            x2 = 5:9; y2 = 5:-1:1;
    end
    
    
    b1 = bar(x1, t_mean_op(y1)); hold on
    b2 = bar(x2, t_mean_op(y2));
    set(b1,'Facecolor', [86 44 136]/255);% [.7, .7, .7])
    set(b2,'Facecolor', [66 140 203]/255);% [.7, .7, .7])
    hold on
    for which_prediction = 1:size( all_prediction ,2)
        model_prediction = all_prediction(  : , which_prediction );
        model_prediction = model_prediction';
        col = col_vector{which_prediction};
        scatter([x1 x2],model_prediction([y1 y2]),...
            ... markersize, 'filled','MarkerFaceColor', col )
            markersize,  col, 'LineWidth', linewidth )
    end
    
    for which_prediction = 1:size( all_prediction ,2)
        model_prediction = all_prediction(  : , which_prediction );
        model_prediction = model_prediction';
        col = col_vector{which_prediction};
        plot(x1, model_prediction(y1), col, 'LineWidth', linewidth);
        plot(x2, model_prediction(y2), col, 'LineWidth', linewidth);
    end
    
    set(gca,'xtick',[mean(x1), mean(x2)]);
    set(gca,'XTickLabel',{'Patterns-Sparsity','Grating-Sparsity'});
    
    h=gca;
    th=rotateticklabel(h,15);
    %set (gca,'position',[0.1,0.2,.8,.75] );
    box off
    
    %legend('data', legend_name, 'Location', 'NorthEast', 'FontSize', 8)
    
end


end
