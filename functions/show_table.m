function [] = show_table(prevPath, which_obj, target,  data_folder, optimizer )

% This is the function to help load data
% the first variable: the path need to input
% the second variable: what kinds of object I want to load, it can be
% BOLD_target, BOLD_pred, param, Rsquare
% the last one is New fit or Old fit

switch which_obj
    
    case 'Rsquare_table'
        for roi = 1:3
            fname = sprintf('Rsqaure_table-%d_roi.mat',roi );
            load_path = fullfile( prevPath, 'Data', data_folder, target, optimizer, fname);
            load( load_path, 'r2_table');
            roi_name = sprintf('-------------------------------------V%d------------------------------', roi);
            disp( roi_name )
            r2_table
        end
        
    case 'param_table'
        for roi = 1:3
            fname = sprintf('param_table-%d_roi.mat',roi );
            load_path = fullfile( prevPath, 'Data', data_folder, target, optimizer, fname);
            load( load_path, 'param_table');
            roi_name = sprintf('-------------------------------------V%d------------------------------', roi);
            disp( roi_name )
            param_table
        end
        
     case 'RMSE_table'
        for roi = 1:3
            fname = sprintf('rmse_table-%d_roi.mat',roi );
            load_path = fullfile( prevPath, 'Data', data_folder, target, optimizer, fname);
            load( load_path, 'rmse_table');
            roi_name = sprintf('-------------------------------------V%d------------------------------', roi);
            disp( roi_name )
            rmse_table
        end
        
end

