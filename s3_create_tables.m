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
model_name = { 'CE', 'SOC', 'OTS', 'NOA'};

% define param name
param_name =  { 'CE: g', 'CE: n',  ...
                                    'SOC: c', 'SOC: g', 'SOC: n', ...
                                    'OTS: w', 'OTS: g', 'OTS: n',...
                                    'NOA: w', 'NOA: g', 'NOA: n',};

% save address
save_address = fullfile(stdnormRootPath, 'Tables', data_folder, target,  'fmincon');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing
T  = chooseData(choose_model, 'fmincon', fittime);

%% init storages

% obtain some features of the storages
nummodels   = length(unique(T.modelNum));
model_vector = [1, 4, 5, 3];
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
modelLoader = T.modelLoader;
numstimuli = 50;

%% create Rsquare tables: 3 (roi) x (model x dataset)

for roi = 1: numrois
    % storages
    R_summay= NaN(nummodels,numdatasets);
    for idx = 1:nummodels
        % obain model index
        model_idx = model_vector(idx);
        for dataset = 1:numdatasets
            % load value
            R_summay(idx, dataset) = ...
                dataloader(stdnormRootPath, 'Rsquare', target, dataset, roi, data_folder, model_idx, 'fmincon');
        end
    end
    
    r2_table = table(model_name', R_summay(:, 1) ,R_summay(:, 2), R_summay(:, 3), R_summay(:, 4));
    r2_table.Properties.VariableNames = {'model', 'DS1', 'DS2', 'DS3', 'DS4' };
    writetable(r2_table, fullfile(save_address , sprintf('Rsquare_table_roi-%d.csv', roi)));
    
end

%% create RMSE tables: 3 (roi) x (model x dataset)

for roi = 1: numrois
    % storages
    R_summay= NaN(nummodels,numdatasets);
    for idx = 1:nummodels
        % obain model index
        model_idx = model_vector(idx);
        for dataset = 1:numdatasets
            
            % load target 
            BOLD_target = dataloader(stdnormRootPath, 'BOLD_target', target, dataset, roi);
            
            % load predction 
            BOLD_pred = dataloader(stdnormRootPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, 'fmincon');
            
            % rmse 
            rmse(idx, dataset) = double(sqrt(mean((BOLD_pred- BOLD_target).^2)));
   
        end
    end
    
    rmse_table = table(model_name', rmse(:, 1), rmse(:, 2), rmse(:, 3), rmse(:, 4));
    rmse_table.Properties.VariableNames = {'model', 'DS1', 'DS2', 'DS3', 'DS4' };
    writetable(rmse_table, fullfile(save_address, sprintf('rmse_table_roi-%d.csv', roi)));
    
end

%%  create param tables: 3 (roi) x (modelx param x dataset)

numparams = length(param_name);

% storages
for roi = 1: numrois
    parammean= NaN(numparams,numdatasets);
    
    for idx = 1:nummodels
        % obain model index and model 
        model_idx = model_vector(idx);
        model = modelLoader{idx};
        
        for dataset = 1:numdatasets
            % desgin index 
            row_idx_array = (idx - 1) * 3+1: idx * 3;
            row_idx = unique(max(1, row_idx_array-1));
            col_idx = (dataset-1) * 2 + 1;
            % load value
            param = model.print_param(dataloader(stdnormRootPath, 'param', target, dataset, roi, data_folder, model_idx, 'fmincon'));
                    
            % assign value 
            if strcmp(cross_valid, 'one')
                parammean(row_idx, col_idx) = param';
                parammean(row_idx, col_idx+1) = NaN(size(param'));
            else
                parammean(row_idx, col_idx) = nanmean(param, 2);
                parammean(row_idx, col_idx +1) = std(param, [], 2);
            end
            
        end
    end
    
    param_table = table(param_name', parammean(:, 1) ,parammean(:, 2), parammean(:, 3), parammean(:, 4), ...
                                                                          parammean(:, 5) ,parammean(:, 6), parammean(:, 7), parammean(:, 8));
    param_table.Properties.VariableNames = {'model', 'dataset1_mean', 'dataset1_sem', ...
                                                     'dataset2_mean', 'dataset2_sem', ...
                                                     'dataset3_mean', 'dataset3_sem', ...
                                                     'dataset4_mean', 'dataset4_sem'};
    writetable(param_table, fullfile(save_address , sprintf('param_table-roi-%d.csv', roi)));
end

%% Create table heterogeneity


roi_sets   = { 'v1', 'v2', 'v3'};
pat_sets   = { 'snakes', 'gratings'};
data_sets  = { 'DS1', 'DS2', 'DS3', 'DS4'};
agent_sets = {  'CE', 'SOC', 'OTS', 'NOA', 'Data'}; 
agent_ind  = [1, 4, 5, 3, 99]; 
row_names  = { };

table_mat = NaN(length(data_sets) * length(agent_sets), ... 
                 length(roi_sets)  * length(pat_sets));

for ii = 1:length(agent_sets)
    for jj = 1:length(data_sets)
        % append the row name 
        row_names{ end+1} = sprintf('%s_%s', ...
                          agent_sets{ii}, data_sets{jj});
        % generate the row index
        r_idx = (ii-1) * length(data_sets) + jj;

        col_names  = {};
        for pp = 1:length(roi_sets)

            % append the col name 
            col_names{ end+1} = sprintf('%s_%s', ...
                                roi_sets{pp}, 'snakes');
            col_names{ end+1} = sprintf('%s_%s', ...
                                roi_sets{pp}, 'gratings');
            % col_idx
            c_idx = (pp-1) * length(pat_sets);

            %% Assign the data to the matrix 
            switch ii
                case { 1, 2, 3, 4}
                    which_obj = 'BOLD_pred';
                    model_idx = agent_ind(ii);
                    BOLD = dataloader(stdnormRootPath, which_obj, 'target',...
                                        jj, pp, data_folder, model_idx, 'fmincon');
                case 5
                    which_obj = 'BOLD_target';
                    BOLD = dataloader(stdnormRootPath, which_obj, 'target', jj, pp);
            end 
            switch jj 
                case { 1, 2}
                    s_ind = [1:5, 15:18];
                    g_ind = [6:14];
                case { 3, 4}
                    s_ind = [5:8, 14:17];
                    g_ind = [1:4, 9:13];
            end 
            table_mat(r_idx, c_idx+1) = mean(BOLD(s_ind));
            table_mat(r_idx, c_idx+2) = mean(BOLD(g_ind));
        end 
    end 
end

T = array2table(table_mat);
T.Properties.VariableNames = col_names;
T.Properties.RowNames = row_names;
writetable(T, fullfile(stdnormRootPath, 'Tables', 'hetero_tables.csv'),'WriteRowNames',true);
