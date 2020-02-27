
T = chooseData('orientation');

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix
[ currPath, prevPath ] = stdnormRootPath();
save_address = fullfile(prevPath, 'Data', 'fitResults', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end
addpath( genpath( fullfile( prevPath, 'Data', 'fMRIdata' ) ) )

for hpc_job_number = 1 : height(T)
    
    dataset     = T.dataset(hpc_job_number);
    roi         = T.roiNum(hpc_job_number);
    which_model = T.modelName{hpc_job_number};
    which_type  = T.typeName{hpc_job_number};
    model_idx   = T.modelNum(hpc_job_number);
    
    disp(T(hpc_job_number,:));
    
    
    if strcmp( which_type, 'orientation' )
        
        % Make predictions
        [ parameters , BOLD_prediction , Rsquare ]=cross_validation(dataset, roi , which_model, which_type , fittime);
        
    elseif strcmp( which_type, 'space')
        
        % Load E_xy
        
        %  In model under orientation category, loading data is a built-in
        %  function, which means we do not need to load the data by ourselves.
        %  However, loading E_xy data takes a lot of time, so here we load E_xy
        %  data first and then introduce them as a new data.
        
        fname = sprintf('E_xy_%02d.mat', dataset);
        tmp = load(fname, 'E_xy');
        E_op = tmp.E_xy; clear tmp;
        
        load(sprintf('dataset%02d.mat', dataset), 'v_mean');
        v_mean_op = v_mean(roi , : );
        
        % generate a disk to prevent edge effect
        [ w_d ] = gen_disk( size(E_op , 1));
        
        % Make the prediction
        switch which_model
            case 'SOC'
                
                [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d);
                
            case 'ori_surround'
                
                % Load weight_E
                fname = sprintf('weight_E_%02d.mat', dataset);
                tmp = load(fname, 'weight_E');
                weight_E = tmp.weight_E; clear tmp;
                          
                [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d, weight_E );
        end
    end
    
    
    % Save the results
    save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'parameters');
    save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'BOLD_prediction');
    save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'Rsquare');
    
end
%


