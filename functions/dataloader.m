function [data] = dataloader(prevPath, which_obj, target, dataset, roi,  data_folder, model, optimizer )

% This is the function to help load data
% the first variable: the path need to input
% the second variable: what kinds of object I want to load, it can be
% BOLD_target, BOLD_pred, param, Rsquare
% the last one is New fit or Old fit

if (nargin < 8), optimizer = []; end
if (nargin < 7), model = []; end
if (nargin < 6), data_folder = []; end

switch which_obj
    
    case 'BOLD_pred'
        fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
        load_path = fullfile( prevPath, 'Data', data_folder, target, optimizer, fname);
        if exist(load_path, 'file')
            load( load_path, 'BOLD_pred');
            data = BOLD_pred;
        else 
            data = [];
        end
        
    case 'BOLD_target'
        fname = sprintf('dataset%02d.mat', dataset);
        load_path = fullfile(prevPath, 'Data','fMRIdata', fname );
        load(load_path, 'v_mean');
        data = v_mean(roi, : ); %matrix: num_roi x num_stim --> vector: num_stimuli 
        if strcmp(target,  'target')
            switch dataset
                case {1}
                    stim_idx = [1:10, 35:38, 47:50];
                    data = data(stim_idx);
                case{2}
                    stim_idx = [1:10, 33:36, 45:48];
                    data = data(stim_idx);
                case{3, 4}
                    stim_idx = [9:12, 26, 28:39];
                    data = data(stim_idx);
            end
        end
        
    case 'BOLD_target_error' 
        fname = sprintf('dataset%02d.mat', dataset);
        load_path = fullfile(prevPath, 'Data','fMRIdata', fname );
        load(load_path, 'BOLD_se');
        data = BOLD_se( roi, :);
        if strcmp(target,  'target')
                    switch dataset
                        case {1}
                            stim_idx = [1:10, 35:38, 47:50];
                            data = data(stim_idx);
                        case{2}
                            stim_idx = [1:10, 33:36, 45:48];
                            data = data(stim_idx);
                        case{3, 4}
                            stim_idx = [9:12, 26, 28:39];
                            data = data(stim_idx);
                    end
        end
        
    case 'param'
        fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
        load_path = fullfile(prevPath, 'Data', data_folder, target, optimizer, fname );
        load( load_path, 'params' )
        data  = params;
        
    case 'Rsquare'
        fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
        load_path = fullfile(prevPath, 'Data', data_folder, target, optimizer, fname );
        load( load_path, 'Rsquare')
        data  = Rsquare;
        
    case 'Loss_log'
               
        fname = sprintf('loss_log_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
        path = fullfile(prevPath, 'Data', data_folder, target, optimizer, fname );
        load( path, 'loss_log')
        data  = loss_log;
        
    case 'E_ori'
        fname = sprintf('E_ori_%02d.mat', dataset);
        path = fullfile(prevPath, 'Data', 'E', fname );
        load( path, 'E_ori');
        data  = E_ori;
        if strcmp(target,  'target')
                    switch dataset
                        case {1}
                            stim_idx = [1:10, 35:38, 47:50];
                            data = data(:, :, stim_idx);
                        case{2}
                            stim_idx = [1:10, 33:36, 45:48];
                            data = data(:, :, stim_idx);
                        case{3, 4}
                            stim_idx = [9:12, 26, 28:39];
                            data = data(:, :, stim_idx);
                    end
        end
        
   case 'E_xy'
        fname = sprintf('E_xy_%02d.mat', dataset);
        path = fullfile(prevPath, 'Data', 'E', fname );
        load( path, 'E_xy');
        data  = E_xy;
        if strcmp(target,  'target')
                    switch dataset
                        case {1}
                            stim_idx = [1:10, 35:38, 47:50];
                            data = data(:, :, :, :, stim_idx);
                        case{2}
                            stim_idx = [1:10, 33:36, 45:48];
                            data = data(:, :, :, :, stim_idx);
                        case{3, 4}
                            stim_idx = [9:12, 26, 28:39];
                            data = data(:, :, :, :, stim_idx);
                    end
        end
        
    case 'Z'
        fname = sprintf('Z_%02d.mat', dataset);
        path = fullfile(prevPath, 'Data', 'E', fname );
        load( path, 'Z');
        data  = Z;
        if strcmp(target,  'target')
                    switch dataset
                        case {1}
                            stim_idx = [1:10, 35:38, 47:50];
                            data = data(:, :, :, :, stim_idx);
                        case{2}
                            stim_idx = [1:10, 33:36, 45:48];
                            data = data(:, :, :, :, stim_idx);
                        case{3, 4}
                            stim_idx = [9:12, 26, 28:39];
                            data = data(:, :, :, :, stim_idx);
                    end
        end
        
   case 'E_mean'
        fname = sprintf('E_mean_%02d.mat', dataset);
        path = fullfile(prevPath, 'Data', 'E', fname );
        load( path, 'E_mean');
        data  = E_mean;
        if strcmp(target,  'target')
                    switch dataset
                        case {1}
                            stim_idx = [1:10, 35:38, 47:50];
                            data = data(:, :, :, :, stim_idx);
                        case{2}
                            stim_idx = [1:10, 33:36, 45:48];
                            data = data(:, :, :, :, stim_idx);
                        case{3, 4}
                            stim_idx = [9:12, 26, 28:39];
                            data = data(:, :, :, :, stim_idx);
                    end
        end
        
    case 'stimuli' 
        fname = sprintf('stimuli-dataset0%1d', dataset);
        path=fullfile(prevPath, 'Data', 'Stimuli', fname);
        load(path, 'stimuli');
        data = double(stimuli);
        
end

end


