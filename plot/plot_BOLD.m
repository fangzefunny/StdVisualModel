function [] = plot_BOLD(BOLD_preds, BOLD_data, BOLD_err, dataset, model_ind, target, plotData)

%{
Inputs:
    BOLD_preds: model prediction
    BOLD_data: human BOLD target
    BOLD_err: human BOLD target's bootstrapped error
    dataset: 1 or 2 or 3 or 4
    model_in: 1, 4, 5, 3
    target: 'All' or 'target'

Ouputs: 
    figure
%}

if ~exist('plotData', 'var') || isempty (plotData), plotData = true; end

% choose colors 
viz = ColorPalette();
dark    = viz.Dark;
blue    = viz.Blue;
red     = viz.Red;
yellow  = viz.Yellow;
green   = viz.Green;
purple  = viz.Purple;
curvy   = [  .4,  .4,  .4] + .1; 
grating = [  .6,  .6,  .6] + .1; 
other   = [  .8,  .8,  .8] + .1;
col_vector = {dark, green, red, blue, yellow, purple};
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
T = T( contains(T.Dataset,sprintf('DS%d',dataset)), :);
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
    if (i < 5) && strcmp(T.Pattern{i}, 'CURVES')
        bar_color = curvy;
    elseif (i < 5) && strcmp(T.Pattern{i}, 'GRATINGS')
        bar_color = grating;
    else
        bar_color = other;
    end
    
    % save data 
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
    if plotData
    bar( materials.x{i}, materials.y_bar{i},... 
        'Facecolor', materials.color{i},... 
        'EdgeColor', materials.color{i});
    % show BOLD target error bar
    errorbar( materials.x{i}, materials.y_bar{i},...
        materials.y_err{i}, materials.y_err{i},...
        'LineStyle', 'none',...
        'Color', [ .5, .5, .5]);
    end
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

