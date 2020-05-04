%% clear the memory

clear all; close all; clc
%% hyperparameter: each time, we only need to edit this section !!

optimizer        = 'bads';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'All';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'noCross';  % save in which folder. value space: 'noCross', .....
cross_valiad   = 'one';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.

%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot' )))

%% generate save address and  choose data

% save address
save_address = fullfile(prevPath, 'Data', data_folder, target,  optimizer);
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing
T      = chooseData( 'orientation', optimizer, fittime );

%% init storages

% obtain some features of the storages
nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
numparams = 3;


%% create Rsquare tables: 3 (roi) x ( model x dataset )

% define model name 
model_name = { 'contrastModel', 'normStdModel', 'normVarModel'};

for roi = 1: numrois
    % storages
    R_summay= NaN(nummodels,numdatasets);
    for model_idx = 1:nummodels
        % obain model index
        for dataset = 1:numdatasets
            % load value
            R_summay( model_idx, dataset ) = ...
                dataloader( prevPath, 'Rsquare', target, dataset, roi, data_folder, model_idx, optimizer);
        end
    end
    
    r2_table = table(model_name', R_summay(:, 1) ,R_summay(:, 2), R_summay(:, 3), R_summay(:, 4));
    r2_table.Properties.VariableNames = {'model', 'dataset1', 'dataset2', 'dataset3', 'dataset4' };
    save(fullfile(save_address , sprintf('Rsqaure_table-%d_roi.mat', roi )) , 'r2_table');
    
end

%%  create param tables: 3 (roi) x ( modelx param x dataset )

param_name =  { 'contrastModel: g', 'contrastModel: n',  ...
                                    'normStdModel: w', 'normStdModel: g', 'normStdModel: n', ...
                                    'normVarModel: w', 'normVarModel: g', 'normVarModel: n' };
numparams = length(param_name);

% storages
for roi = 1: numrois
    mean= NaN(numparams,numdatasets);
    
    for model_idx = 1:nummodels
        % obain model index
        for dataset = 1:numdatasets
            % desgin index 
            row_idx_array = (model_idx - 1) * 3+1: model_idx * 3;
            row_idx = unique( max( 1, row_idx_array-1) );
            col_idx = (dataset-1) * 2 + 1;
            % load value  
            param = dataloader( prevPath, 'param', target, dataset, roi, data_folder, model_idx, optimizer);
            % assign value 
            mean( row_idx, col_idx ) = param';
            mean( row_idx, col_idx+1) = NaN( size(param'));
            
        end
    end
    
    param_table = table(param_name', mean(:, 1) ,mean(:, 2), mean(:, 3), mean(:, 4), ...
                                                                          mean(:, 5) ,mean(:, 6), mean(:, 7), mean(:, 8));
    param_table.Properties.VariableNames = {'model', 'dataset1: mean', 'dataset1: sem', ...
                                                                                                         'dataset2: mean', 'dataset2: sem', ...
                                                                                                         'dataset3: mean', 'dataset3: sem', ...
                                                                                                         'dataset4: mean', 'dataset4: sem'};
    save(fullfile(save_address , sprintf('param_table-%d_roi.mat', roi )) , 'param_table');
    
end

%% show table

% show R square table  
show_table( prevPath, 'Rsquare_table', target, data_folder, optimizer); 
show_table( prevPath, 'param_table', target, data_folder, optimizer); 
