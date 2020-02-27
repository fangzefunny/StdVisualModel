function [data] = dataloader(prevPath, which_obj, dataset, roi, model,  NeworOld )

% This is the function to help load data
% the first variable: the path need to input
% the second variable: what kinds of object I want to load, it can be
% BOLD_target, BOLD_pred, param, Rsquare
% the last one is New fit or Old fit

if (nargin < 6), NeworOld = 'new'; end
if (nargin < 5), model = []; end

addpath( genpath( fullfile( prevPath, 'Data', 'fMRIdata')))
addpath( genpath( fullfile( prevPath, 'Data', 'Stimuli')))
addpath( genpath( fullfile( prevPath, 'Data', 'E')))

switch NeworOld
    case "new"
        switch which_obj
            
            case 'BOLD_target'
                
                fname = sprintf('dataset%02d.mat', dataset);
                load(fname, 'v_mean');
                data = v_mean(roi, : ); %matrix: num_roi x num_stim
                
            case 'BOLD_pred'
                
                fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                pred = fullfile(prevPath, 'Data','fitResults', 'All stimulus classes', fname );
                load( pred, 'BOLD_prediction');
                BOLD_pred = BOLD_prediction;
                data  = BOLD_pred;
                
            case 'param'
                
                fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                param = fullfile(prevPath, 'Data','fitResults', 'All stimulus classes', fname );
                data  = param;
                
            case 'Rsquare'
                
                fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                Rsquare = fullfile(prevPath, 'Data','fitResults', 'All stimulus classes', fname );
                data  = Rsquare;
                
            case 'E_ori'
                
                fname = sprintf('E_ori_%02d.mat', dataset);
                path = fullfile(prevPath, 'Data', 'E', fname );
                load( path, 'E_ori');
                data  = E_ori;
                
        end
        
    case "old"
        switch which_obj
            
            case 'BOLD_target'
                
                fname = sprintf('dataset%02d.mat', dataset);
                load(fname, 'v_mean');
                data = v_mean(roi, : ); %matrix: num_roi x num_stim
                
            case 'BOLD_pred'
                
                fname = sprintf('prediction_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                pred = fullfile(prevPath, 'Data','fitResult', 'All stimulus classes', fname );
                load( pred, 'BOLD_prediction');
                BOLD_pred = BOLD_prediction;
                data  = BOLD_pred;
                
            case 'param'
                
                fname = sprintf('parameters_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                param = fullfile(prevPath, 'Data','fitResult', 'All stimulus classes', fname );
                data  = param;
                
            case 'Rsquare'
                
                fname = sprintf('Rsquare_data-%01d_roi-%01d_model-%01d.mat', dataset, roi, model );
                Rsquare = fullfile(prevPath, 'Data','fitResult', 'All stimulus classes', fname );
                data  = Rsquare;
                
            case 'E_ori'
                
                fname = sprintf('E_ori_%02d.mat', dataset);
                E_ori = fullfile(prevPath, 'Data', 'E', fname );
                load( path, 'E_ori');
                data  = E_ori;
                
        end
end

end

