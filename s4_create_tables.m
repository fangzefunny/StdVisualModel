%% clear the memory

clear all; close all; clc
%% hyperparameter: each time, we only need to edit this section !!

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'target';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'noCross';  % save in which folder. value space: 'noCross', .....
cross_valid   = 'one';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_data = 'all';          % choose some preset data

% define model name 
model_name = { 'contrast', 'normVar', 'soc', 'oriSurrond'};

% define param name
param_name =  { 'contrastModel: g', 'contrastModel: n',  ...
                                    'normVarModel: w', 'normVarModel: g', 'normVarModel: n', ...
                                     'socModel: c', 'socModel: g', 'socModel: n', ...
                                    'oriSurroundModel: w', 'oriSurroundModel: g', 'oriSurroundModel: n'};

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
T      = chooseData( choose_data, optimizer, fittime );

%% init storages

% obtain some features of the storages
nummodels   = length(unique(T.modelNum));
model_vector = [ 1, 3, 4, 5];
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
numparams = 3;

%% create Rsquare tables: 3 (roi) x ( model x dataset )

for roi = 1: numrois
    % storages
    R_summay= NaN(nummodels,numdatasets);
    for idx = 1:nummodels
        % obain model index
        model_idx = model_vector(idx);
        for dataset = 1:numdatasets
            % load value
            R_summay( idx, dataset ) = ...
                dataloader( prevPath, 'Rsquare', target, dataset, roi, data_folder, model_idx, optimizer);
        end
    end
    
    r2_table = table(model_name', R_summay(:, 1) ,R_summay(:, 2), R_summay(:, 3), R_summay(:, 4));
    r2_table.Properties.VariableNames = {'model', 'dataset1', 'dataset2', 'dataset3', 'dataset4' };
    save(fullfile(save_address , sprintf('Rsqaure_table-%d_roi.mat', roi )) , 'r2_table');
    
end

%% create RMSE tables: 3 (roi) x ( model x dataset )

for roi = 1: numrois
    % storages
    R_summay= NaN(nummodels,numdatasets);
    for idx = 1:nummodels
        % obain model index
        model_idx = model_vector(idx);
        for dataset = 1:numdatasets
            
            % load target 
            BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi);
            
            % load predction 
            BOLD_pred = dataloader( prevPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, optimizer);
            
            % rmse 
            rmse( idx, dataset) = double(sqrt(mean((BOLD_pred- BOLD_target).^2)));
   
        end
    end
    
    rmse_table = table(model_name', rmse(:, 1), rmse(:, 2), rmse(:, 3), rmse(:, 4));
    rmse_table.Properties.VariableNames = {'model', 'dataset1', 'dataset2', 'dataset3', 'dataset4' };
    save(fullfile(save_address , sprintf('rmse_table-%d_roi.mat', roi )) , 'rmse_table');
    
end

%%  create param tables: 3 (roi) x ( modelx param x dataset )


numparams = length(param_name);

% storages
for roi = 1: numrois
    parammean= NaN(numparams,numdatasets);
    
    for idx = 1:nummodels
        % obain model index
        model_idx = model_vector(idx);
        
        for dataset = 1:numdatasets
            % desgin index 
            row_idx_array = (idx - 1) * 3+1: idx * 3;
            row_idx = unique( max( 1, row_idx_array-1) );
            col_idx = (dataset-1) * 2 + 1;
            % load value  
            if model_idx <5
                param = exp(dataloader( prevPath, 'param', target, dataset, roi, data_folder, model_idx, optimizer));
            else
                param = dataloader( prevPath, 'param', target, dataset, roi, data_folder, model_idx, optimizer);
            end
            % assign value 
            if strcmp( cross_valid, 'one')
                parammean( row_idx, col_idx ) = param';
                parammean( row_idx, col_idx+1) = NaN( size(param'));
            else
                parammean( row_idx, col_idx ) = mean(param, 2);
                parammean( row_idx, col_idx +1 ) = std(param, [], 2);
            end
            
        end
    end
    
    param_table = table(param_name', parammean(:, 1) ,parammean(:, 2), parammean(:, 3), parammean(:, 4), ...
                                                                          parammean(:, 5) ,parammean(:, 6), parammean(:, 7), parammean(:, 8));
    param_table.Properties.VariableNames = {'model', 'dataset1: mean', 'dataset1: sem', ...
                                                                                                         'dataset2: mean', 'dataset2: sem', ...
                                                                                                         'dataset3: mean', 'dataset3: sem', ...
                                                                                                         'dataset4: mean', 'dataset4: sem'};
    save(fullfile(save_address , sprintf('param_table-%d_roi.mat', roi )) , 'param_table');
    
end

%% show table

% show R square table  
show_table( prevPath, 'Rsquare_table', target, data_folder, optimizer); 
show_table( prevPath, 'RMSE_table', target, data_folder, optimizer);
show_table( prevPath, 'param_table', target, data_folder, optimizer); 
