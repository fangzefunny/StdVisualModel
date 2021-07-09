function legend_list = plot_BOLD(BOLD_preds, BOLD_data, BOLD_err, dataset, model_ind, target)

% Input 1: which datasets: dataset 1 or 2...
% Input 2: which roi area: 'v1' or 'v2' ...
% input 3: the prediction of the model: a matrix: num_stim x num_models
% Input 4: legend name:
% Input 5: This is prepared for arbitrary input: like two class

% choose colors 
dark = [52, 73, 94]./255;
blue = [52, 152, 219]./255;
red = [231, 76, 60]./255;
yellow = [ 241, 196, 15]./255;
green = [46, 204, 113]./255;
curvy = [ .4, .4, .4] + .1; 
grating = [ .6, .6, .6] + .1; 
other = [ .8, .8, .8] + .1;
col_vector = {dark, green, red, blue, yellow};
col_vector = col_vector(model_ind);

% fix visualize hyperparams
fontsize = 12;
linewidth = 1.2;
plotwidth = 1.5;
markersize = 4.5;
set (gca, 'FontSize', fontsize, 'LineWidth', linewidth); hold on;

% get the data shape 
% Model dimensions: M
% Stimuli dimensions: N
% Roi dimensions: R
n_models = size( BOLD_preds, 1);

% decide the plot scale
y_min = min( 0, min( BOLD_data));
switch dataset
    case {1}
        y_max = 1.6;
    case {2}
        y_max = 2.5;
    case {3, 4}
        y_max = 3;
end 

% select the visualize families using the 
% supplementary table and filter the target data
T = readtable( fullfile(stdnormRootPath, 'Tables/SupplememtaryTable3.csv'));
T = T( find(contains(T.Dataset,sprintf('DS%d',dataset))), :);
nrows = size(T,1);
% the first 4th rows are our targets
if strcmp( target, 'target')
    nrows = 4;
    y_max = inf;
end

% store the material in a structure
materials = struct();
materials.x     = {};
materials.y_bar = {};
materials.y_err = {};
materials.y_hat = {};
materials.color = {};
end_idx = 0;

for i = 1:nrows
    idx = str2num( T.Number{i});
    if strcmp( target, 'target')
        if length(idx) == 10
            idx = [ 26, 28:30];
        end
        nx  = length(idx)+1;
    else
        nx  = max( 6, length(idx)+1);
    end
    start_idx = end_idx + 1;
    end_idx = start_idx + nx - 1;
    x = start_idx:end_idx;
    y_bar = NaN(1,nx);
    y_bar( 1:length(idx)) = BOLD_data(idx);
    y_err = NaN(1,nx);
    y_err( 1:length(idx)) = BOLD_err(idx);
    y_hat = NaN(n_models,nx);
    y_hat( :, 1:length(idx)) = BOLD_preds( :, idx);
    if strcmp(T.Pattern{i}, 'CURVES')
        bar_color = curvy;
    elseif strcmp(T.Pattern{i}, 'GRATINGS')
        bar_color = grating;
    else
        bar_color = other;
    end
    
    materials.x{ end+1}     = x;
    materials.y_bar{ end+1} = y_bar;
    materials.y_err{ end+1} = y_err;
    materials.y_hat{ end+1} = y_hat;
    materials.color{ end+1} = bar_color;
end

% hold on, the follow contents are on the same figure
hold on

% loop over to show figures
for i = 1:nrows

    % show BOLD target 
    bar( materials.x{i}, materials.y_bar{i},... 
        'Facecolor', materials.color{i},... 
        'EdgeColor', materials.color{i});
    % show BOLD target error bar
    errorbar( materials.x{i}, materials.y_bar{i},...
        materials.y_err{i}, materials.y_err{i},...
        'LineStyle', 'none',...
        'Color', [ .5, .5, .5]);
    % loop to plot all model predictions
    for j = 1:n_models
        col = col_vector{j};
        plot( materials.x{i}, materials.y_hat{i}(j,:),... 
             '-o', 'MarkerSize', markersize,...
             'MarkerEdgeColor', col, ...
             'MarkerFaceColor', col,...
             'LineWidth', plotwidth,...
             'Color', col);
    end
end
xticklabels([])
ylim( [y_min, y_max])
box off
hold off

end

