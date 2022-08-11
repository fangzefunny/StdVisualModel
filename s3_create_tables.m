%% hyperparameter: each time, we only need to edit this section !!
if ~exist('doCross', 'var'), doCross = false; end
if ~exist('target', 'var'),  target  = 'target'; end % 'target' or 'all';

fittime      = [];         % how manoy initialization. value space: Integer
choose_model = 'test';      % choose some preset data  ('all' or 'noOri');
error_bar    = false;
round2n      = 3;

switch doCross
    case false
        cross_valid  = 'one';           % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'noCross';       % save in which folder. value space: 'noCross', .....
        print_loss   = true;

    case true
        cross_valid  = 'cross_valid';   % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'Cross';         % save in which folder. value space: 'noCross', .....
        print_loss   = false;           % we don't save all the loss plots when we cross validate
end

%% load the model info

% all models
modelLoader  = {contrastModel(),...    % published model
                SOCModel(),...    
                oriSurroundModel(),... % norm over space & orientation 
                normModel(),... 
                normVarModel()};       % norm over orientation

% save address
save_address = fullfile(stdnormRootPath, 'Tables', data_folder, target,  'fmincon');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing
T  = chooseData(choose_model, 'fmincon', fittime);

% obtain some features of the storages
model_ind   = sort(unique(T.modelNum));
nummodels   = length(model_ind);
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli  = 50;

% obtain the selected model's names, param_name
model_names  = {};
param_names  = {};
fparam_names = {};
for idx = 1:nummodels
    model = modelLoader{model_ind(idx)};
    model_names{end+1} = model.legend;
    for j = 1:model.num_param
        param_names{end+1}  = sprintf('%s: %s', model.legend, model.param_name{j});
        fparam_names{end+1} = sprintf('%s: %s', model.legend, model.fparam_name{j});
    end
end
numparams = length(param_names);

% obtain the table columns 
Rtable_cols      = {'model'}; 
paramtable_cols  = {'model'};
for i = 1:numdatasets
    Rtable_cols{end+1}     = sprintf('DS%d',i);
    paramtable_cols{end+1} = sprintf('DS%d_mean', i);
    paramtable_cols{end+1} = sprintf('DS%d_sem', i);
end

%% create Rsquare tables: 3 (roi) x (model x dataset)
for roi = 1: numrois
    % storages
    R_summay= NaN(nummodels,numdatasets);
    for idx = 1:nummodels
        % obain model index
        model_idx = model_ind(idx);
        for dataset = 1:numdatasets
            % load value and round to 3 decimal 
            R_summay(idx, dataset) = ...
                round(dataloader(stdnormRootPath, 'Rsquare', target, dataset, roi, data_folder, model_idx, 'fmincon'), round2n);
        end
    end
    
    r2_table = table(model_names', R_summay(:, 1) ,R_summay(:, 2), R_summay(:, 3), R_summay(:, 4));
    r2_table.Properties.VariableNames = Rtable_cols;
    writetable(r2_table, fullfile(save_address , sprintf('Rsquare_table_roi-%d.csv', roi)));
    
end

%% create RMSE tables: 3 (roi) x (model x dataset)

for roi = 1: numrois
    % storages
    rmse= NaN(nummodels,numdatasets);
    for idx = 1:nummodels
        % obain model index
        model_idx = model_ind(idx);
        for dataset = 1:numdatasets
            
            % load target 
            BOLD_target = dataloader(stdnormRootPath, 'BOLD_target', target, dataset, roi);
            
            % load predction 
            BOLD_pred = dataloader(stdnormRootPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, 'fmincon');
            
            % rmse 
            rmse(idx, dataset) = round(double(sqrt(mean((BOLD_pred- BOLD_target).^2))), round2n);
   
        end
    end
    
    rmse_table = table(model_names', rmse(:, 1), rmse(:, 2), rmse(:, 3), rmse(:, 4));
    rmse_table.Properties.VariableNames = Rtable_cols;
    writetable(rmse_table, fullfile(save_address, sprintf('rmse_table_roi-%d.csv', roi)));
    
end

%%  create param tables: 3 (roi) x (modelx param x dataset)

% storages
for roi = 1: numrois
    parammean  = NaN(numparams,numdatasets*2);
    fparammean = NaN(numparams,numdatasets*2);
    
    for idx = 1:nummodels
        % obain model index and model 
        model_idx = model_ind(idx);
        model = modelLoader{model_idx};
        
        for ds = 1:numdatasets
            % desgin index 
            row_idx_array = (idx - 1) * 3+1: idx * 3;
            row_idx = unique(max(1, row_idx_array-1));
            col_idx = (ds-1) * 2 + 1;
            % load value
            % the reparameterized params (interpertable parameter)
            param = model.print_param(model, dataloader(stdnormRootPath, 'param',...
                                target, ds, roi, data_folder, model_idx, 'fmincon'));
            % the fitted params ( 
            fparam = model.print_fparam(model, dataloader(stdnormRootPath, 'param',...
                                target, ds, roi, data_folder, model_idx, 'fmincon'));
            
            % assign value 
            if strcmp(cross_valid, 'one')
                parammean(row_idx, col_idx)    = param';
                parammean(row_idx, col_idx+1)  = NaN(size(param'));
                fparammean(row_idx, col_idx)   = fparam';
                fparammean(row_idx, col_idx+1) = NaN(size(fparam'));
            else
                parammean(row_idx, col_idx)    = nanmean(param, 2);
                parammean(row_idx, col_idx +1) = std(param, [], 2);
                fparammean(row_idx, col_idx)   = nanmean(fparam, 2);
                fparammean(row_idx, col_idx+1) = std(size(fparam'));
            end
            
        end
    end
    
    param_table = table(param_names', parammean(:, 1) ,parammean(:, 2), parammean(:, 3), parammean(:, 4), ...
                                      parammean(:, 5) ,parammean(:, 6), parammean(:, 7), parammean(:, 8));
    param_table.Properties.VariableNames = paramtable_cols;
    fparam_table = table(fparam_names', fparammean(:, 1) , fparammean(:, 2), fparammean(:, 3), fparammean(:, 4), ...
                                       fparammean(:, 5) , fparammean(:, 6), fparammean(:, 7), fparammean(:, 8));
    fparam_table.Properties.VariableNames = paramtable_cols;
    writetable(param_table, fullfile(save_address , sprintf('param_table-roi-%d.csv', roi)));
    writetable(fparam_table, fullfile(save_address , sprintf('fparam_table-roi-%d.csv', roi)));
end

%% Create table heterogeneity

% 
% roi_sets   = {'v1', 'v2', 'v3'};
% pat_sets   = {'snakes', 'gratings'};
% data_sets  = {'DS1', 'DS2', 'DS3', 'DS4'};
% agent_sets = {'CE', 'SOC', 'OTS', 'NOA', 'Data'}; 
% agent_ind  = [1, 4, 5, 3, 99]; 
% row_names  = {};
% 
% table_mat = NaN(length(data_sets) * length(agent_sets), ... 
%                  length(roi_sets)  * length(pat_sets));
% 
% for ii = 1:length(agent_sets)
%     for jj = 1:length(data_sets)
%         % append the row name 
%         row_names{ end+1} = sprintf('%s_%s', ...
%                           agent_sets{ii}, data_sets{jj});
%         % generate the row index
%         r_idx = (ii-1) * length(data_sets) + jj;
% 
%         col_names  = {};
%         for pp = 1:length(roi_sets)
% 
%             % append the col name 
%             col_names{ end+1} = sprintf('%s_%s', ...
%                                 roi_sets{pp}, 'snakes');
%             col_names{ end+1} = sprintf('%s_%s', ...
%                                 roi_sets{pp}, 'gratings');
%             % col_idx
%             c_idx = (pp-1) * length(pat_sets);
% 
%             %% Assign the data to the matrix 
%             switch ii
%                 case {1, 2, 3, 4, 5}
%                     which_obj = 'BOLD_pred';
%                     model_idx = agent_ind(ii);
%                     BOLD = dataloader(stdnormRootPath, which_obj, 'target',...
%                                         jj, pp, data_folder, model_idx, 'fmincon');
%                 case 6
%                     which_obj = 'BOLD_target';
%                     BOLD = dataloader(stdnormRootPath, which_obj, 'target', jj, pp);
%             end 
%             switch jj 
%                 case { 1, 2}
%                     s_ind = [1:5, 15:18];
%                     g_ind = 6:14;
%                 case { 3, 4}
%                     s_ind = [5:8, 14:17];
%                     g_ind = [1:4, 9:13];
%             end 
% 
%             table_mat(r_idx, c_idx+1) = mean(BOLD(s_ind));
%             table_mat(r_idx, c_idx+2) = mean(BOLD(g_ind));
%         end 
%     end 
% end
% 
% T = array2table(table_mat);
% T.Properties.VariableNames = col_names;
% T.Properties.RowNames = row_names;
% writetable(T, fullfile(stdnormRootPath, 'Tables', 'hetero_tables.csv'),'WriteRowNames',true);
