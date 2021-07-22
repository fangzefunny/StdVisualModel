%% hyperparameter: each time, we only need to edit this section !!
if ~exist('doCross', 'var'), doCross = false; end
if ~exist('target', 'var'),  target  = 'all'; end % 'target' or 'All';

fittime          = [];         % how manoy initialization. value space: Integer
choose_model     = 'all';      % choose some preset data  ('all' or 'noOri');
error_bar        = false;

switch doCross
    case false
        cross_valid  = 'one';            % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'noCross';       % save in which folder. value space: 'noCross', .....
        print_loss   = true;

    case true
        cross_valid  = 'cross_valid';   % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'Cross';         % save in which folder. value space: 'noCross', .....
        print_loss   = false;           % we don't save all the loss plots when we cross validate

end

%% define model name 
model_name = { 'contrast', 'soc', 'oriSurrond', 'normVar'};

% define param name
param_name =  { 'contrastModel: g', 'contrastModel: n',  ...
                                     'socModel: c', 'socModel: g', 'socModel: n', ...
                                    'oriSurroundModel: w', 'oriSurroundModel: g', 'oriSurroundModel: n',...
                                    'normVarModel: w', 'normVarModel: g', 'normVarModel: n'};

% save address
save_address = fullfile( stdnormRootPath, 'Tables', data_folder, target,  'fmincon');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing
T  = chooseData( choose_model, 'fmincon', fittime );

%% init storages

% obtain some features of the storages
nummodels   = length(unique(T.modelNum));
model_vector = [ 1, 4, 5, 3];
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;

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
                dataloader( stdnormRootPath, 'Rsquare', target, dataset, roi, data_folder, model_idx, 'fmincon');
        end
    end
    
    r2_table = table(model_name', R_summay(:, 1) ,R_summay(:, 2), R_summay(:, 3), R_summay(:, 4));
    r2_table.Properties.VariableNames = {'model', 'DS1', 'DS2', 'DS3', 'DS4' };
    writetable( r2_table, fullfile(save_address , sprintf('Rsquare_table_roi-%d.csv', roi )));
    
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
            BOLD_target = dataloader( stdnormRootPath, 'BOLD_target', target, dataset, roi);
            
            % load predction 
            BOLD_pred = dataloader( stdnormRootPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, 'fmincon');
            
            % rmse 
            rmse( idx, dataset) = double(sqrt(mean((BOLD_pred- BOLD_target).^2)));
   
        end
    end
    
    rmse_table = table(model_name', rmse(:, 1), rmse(:, 2), rmse(:, 3), rmse(:, 4));
    rmse_table.Properties.VariableNames = {'model', 'DS1', 'DS2', 'DS3', 'DS4' };
    writetable( rmse_table, fullfile(save_address, sprintf('rmse_table_roi-%d.csv', roi )));
    
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
            if model_idx < 6
                param = exp(dataloader( stdnormRootPath, 'param', target, dataset, roi, data_folder, model_idx, 'fmincon'));
            else
                param = (dataloader( stdnormRootPath, 'param', target, dataset, roi, data_folder, model_idx, 'fmincon'));
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
    param_table.Properties.VariableNames = {'model', 'dataset1_mean', 'dataset1_sem', ...
                                                                                                         'dataset2_mean', 'dataset2_sem', ...
                                                                                                         'dataset3_mean', 'dataset3_sem', ...
                                                                                                         'dataset4_mean', 'dataset4_sem'};
    writetable( param_table, fullfile(save_address , sprintf('param_table-roi-%d.csv', roi )));
end

