%% clear the memory
close all; 
clc; 

%% hyperparameter: each time, we only need to edit this section !! 
target       = 'all';  % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime      = 40;     % how manoy initialization. value space: Integer
cross_valid  = 'cross_valid';  % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_model = 'soc';  % choose some preset data 

% save address 
% choose fold according to the cross validation method
if strcmp( cross_valid,'one')
    data_folder    = 'noCross';
elseif strcmp( cross_valid, 'cross_valid')
    data_folder    = 'Cross';
end
save_address = fullfile(stdnormRootPath, 'Data', data_folder, target,  'fmincon');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing 
T = chooseData( choose_model, 'fmincon', fittime );

%% start loop
len = size( T, 1 );

for job = 1: len
    
    % obtrain data index
    dataset = T.dataset( job );
    
    % obtrain  roi index 
    roi = T.roiNum( job );
    
    % obain model index
    model_idx = T.modelNum(job);
    
    % display information to keep track
    display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
    disp( display )
    
    % load model
    model = T.modelLoader{job};
    
    % load training label
    BOLD_target = dataloader( stdnormRootPath, 'BOLD_target', target, dataset, roi );
    
    % load the input stimuli
    switch model.model_type
        case 'orientation'
            which_obj ='E_ori';
        case 'space'
            which_obj = 'E_xy';
    end
    E = dataloader( stdnormRootPath, which_obj, target, dataset, roi, 'old' );
    
    if strcmp( model.legend, 'oriSurround')
        disp( 'ori_surround')

        % gain weight E
        weight_E = dataloader( stdnormRootPath, 'weight_E', target, dataset, roi );
        
        % fit the data without cross validation: knock-1-out, don't show the fit
        [BOLD_pred, params, Rsquare, model] = ...
            model.fit( model, E, weight_E, BOLD_target, 'off' , cross_valid);
        
    else 
        % fit the data without cross validation: knock-1-out, don't show the fit
        [BOLD_pred, params, Rsquare, model] = ...
            model.fit( model, E, BOLD_target, 'off', cross_valid, save_info);
    end
    
    if strcmp( cross_valid, 'one')
        loss_log = model.loss_log;
    end
    
    % save data
    save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'params');
    save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'BOLD_pred');
    save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'Rsquare');
    if strcmp( cross_valid, 'one')
        save(fullfile(save_address , sprintf('loss_log_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'loss_log');
    end
    
end



