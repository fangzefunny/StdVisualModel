function [data] = dataloader(prevPath, which_obj, target, dataset, roi,  NeworOld, model )

% This is the function to help load data
% the first variable: the path need to input
% the second variable: what kinds of object I want to load, it can be
% BOLD_target, BOLD_pred, param, Rsquare
% the last one is New fit or Old fit

if (nargin < 7), model = []; end
if (nargin < 6), NeworOld = 'new'; end

addpath( genpath( fullfile( prevPath, 'Data', 'fMRIdata')))
addpath( genpath( fullfile( prevPath, 'Data', 'Stimuli')))
addpath( genpath( fullfile( prevPath, 'Data', 'E')))

switch NeworOld
    case "new"
        switch which_obj
            
            case 'BOLD_target'
                
                fname = sprintf('dataset%02d.mat', dataset);
                path = fullfile(prevPath, 'Data','fMRIdata', fname );
                load(path, 'v_mean');
                data = v_mean(roi, : ); %matrix: num_roi x num_stim
                
                if strcmp(target,  'target')
                    switch dataset
                        case {1, 2}
                            data = data(1:10);
                        case{3, 4, 5}
                            data = data(31:39);
                    end
                end
                
            case 'BOLD_pred'
                
                if strcmp(target,  'target')
                    fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path= fullfile(prevPath, 'Data','new', 'Target stimulus classes', fname );
                    load( path, 'BOLD_pred');
                    data = BOLD_pred;
                    
                    switch dataset
                        case {1, 2}
                            data = data(1:10);
                        case{3, 4, 5}
                            data = data(31:39);
                    end
                else
                    fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path= fullfile(prevPath, 'Data','new', 'All stimulus classes', fname );
                    load( path, 'BOLD_pred');
                    data = BOLD_pred;
                end
                
                
            case 'param'
                
                fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                path = fullfile(prevPath, 'Data','new', 'All stimulus classes', fname );
                load( path, 'params' )
                data  = params;
                
            case 'Rsquare'
                
                fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                path = fullfile(prevPath, 'Data','new', 'All stimulus classes', fname );
                load( path, 'Rsquare')
                data  = Rsquare;
                
            case 'E_ori'
                
                fname = sprintf('E_ori_%02d.mat', dataset);
                path = fullfile(prevPath, 'Data', 'E_new', fname );
                load( path, 'E_ori');
                data  = E_ori;
                
            case 'stimuli'
                fname = sprintf('stimuli-dataset0%01d', dataset);
                path=fullfile(prevPath, 'Data', 'Stimuli', fname);
                load(path, 'stimuli')
                data = stimuli;
                
        end
        
    case "old"
        switch which_obj
            
            case 'BOLD_target'
                
                fname = sprintf('dataset%02d.mat', dataset);
                path = fullfile(prevPath, 'Data','fMRIdata', fname );
                load(path, 'v_mean');
                data = v_mean(roi, : ); %matrix: num_roi x num_stim
                
            case 'BOLD_pred'
                
                fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                path = fullfile(prevPath, 'Data','fitResult', 'All stimulus classes', fname );
                load( path, 'BOLD_prediction');
                BOLD_pred = BOLD_prediction;
                data  = BOLD_pred;
                
            case 'param'
                
                fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                path = fullfile(prevPath, 'Data','fitResult', 'All stimulus classes', fname );
                load( path, 'parameters' )
                data  = parameters;
                
            case 'Rsquare'
                
                fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                Rsquare = fullfile(prevPath, 'Data','fitResult', 'All stimulus classes', fname );
                data  = Rsquare;
                
            case 'E_ori'
                
                fname = sprintf('E_ori_%02d.mat', dataset);
                path = fullfile(prevPath, 'Data', 'E', fname );
                load( path, 'E_ori');
                data  = E_ori;
                
                 if strcmp(target,  'target')
                    switch dataset
                        case {1, 2}
                            data = data(:, :, 1:10);
                        case{3, 4, 5}
                            data = data(:, :, 31:39);
                    end
                end
                
            case 'stimuli'
                
                fname = sprintf('stimuli-dataset0%1d_orig', dataset);
                path=fullfile(prevPath, 'Data', 'Stimuli', fname);
                load(path, 'stimuli')
                data = double(stimuli)./255 - .5;
                
        end
        
    case 'no_cross'
        
        switch which_obj
            
            case 'BOLD_target'
                
                fname = sprintf('dataset%02d.mat', dataset);
                path = fullfile(prevPath, 'Data','fMRIdata', fname );
                load(path, 'v_mean');
                data = v_mean(roi, : ); %matrix: num_roi x num_stim
                
                if strcmp(target,  'target')
                    switch dataset
                        case {1, 2}
                            data = data(1:10);
                        case{3, 4, 5}
                            data = data(31:39);
                    end
                end
                
            case 'BOLD_pred'
                
                if strcmp(target,  'target')
                    fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path= fullfile(prevPath, 'Data','noCross', 'Target stimulus classes', fname );
                    load( path, 'BOLD_pred');
                    data = BOLD_pred;
                else
                    fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path= fullfile(prevPath, 'Data','noCross', 'All stimulus classes', fname );
                    load( path, 'BOLD_pred');
                    data = BOLD_pred;
                end
                
            case 'E_ori'
                
                fname = sprintf('E_ori_%02d.mat', dataset);
                path = fullfile(prevPath, 'Data', 'E', fname );
                load( path, 'E_ori');
                data  = E_ori;
                
                if strcmp(target,  'target')
                    switch dataset
                        case {1, 2}
                            data = data(:, :, 1:10);
                        case{3, 4, 5}
                            data = data(:, :, 31:39);
                    end
                end
                
            case 'param'
                if strcmp(target,  'target')
                    fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path = fullfile(prevPath, 'Data','noCross', 'Target stimulus classes', fname );
                    load( path, 'parameters' )
                    data  = parameters;
                else
                    fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path = fullfile(prevPath, 'Data','noCross', 'All stimulus classes', fname );
                    load( path, 'parameters' )
                    data  = parameters;
                end
                
            case 'Rsquare'
                
                if strcmp(target,  'target')
                    fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    Rsquare = fullfile(prevPath, 'Data','noCross', 'Target stimulus classes', fname );
                    data  = Rsquare;
                else
                    fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    Rsquare = fullfile(prevPath, 'Data','noCross', 'All stimulus classes', fname );
                    data  = Rsquare;
                end
                
            case 'Loss_log'
                
                if strcmp(target,  'target')
                    fname = sprintf('loss_log_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path = fullfile(prevPath, 'Data','noCross', 'Target stimulus classes', fname );
                    load( path, 'loss_log')
                    data  = loss_log;
                else
                    fname = sprintf('loss_log_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                    path = fullfile(prevPath, 'Data','noCross', 'All stimulus classes', fname );
                    load( path, 'loss_log')
                    data  = loss_log;
                end
                
        end
        
end

end


