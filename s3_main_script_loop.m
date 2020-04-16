%% set path

[curPath, prevPath] = stdnormRootPath();
save_address = fullfile(prevPath, 'Data', 'noCross', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot_tools' )))

%% choose data and hyperparameter

T = chooseData( 'data5' );

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
    model = T.modelLoader{model_idx};
    
    % load training label
    BOLD_target = dataloader( prevPath, 'BOLD_target', dataset, roi );
    
    % load the input stimuli
    switch model.model_type
        case 'orientation'
            data_type ='E_ori';
        case 'space'
            data_type = 'E_xy';
    end
    E = dataloader( prevPath, data_type, dataset, roi, 'old' );
    
    % fit the data without cross validation: knock-1-out, don't show the fit 
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit( model, E, BOLD_target, 'off' );
    
    loss_log = model.loss_log;
    
    % save data
    save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'params');
    save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'BOLD_pred');
    save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'Rsquare');
    save(fullfile(save_address , sprintf('loss_log_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'loss_log');
  
    
end


