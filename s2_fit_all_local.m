%% hyperparameter: each time, we only need to edit this section !! 

optimizer           = 'fmincon'; % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
fittime             = 40;         % how many initialization. value space: Integer
choose_model        = 'soc';     % choose some preset data 
verbose             = 'off'; %'off'; 
doCross             = false;
target              = 'all';

switch doCross
    case false
        cross_valid = 'one';            % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'noCross';       % save in which folder. value space: 'noCross', .....
    case true
        cross_valid  = 'cross_valid';   % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'Cross';         % save in which folder. value space: 'noCross', .....
end

%% generate save address and  choose data 

% save address 
save_address = fullfile( stdnormRootPath, 'Data', data_folder, target,  optimizer);
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing 
T      = chooseData( choose_model, optimizer, fittime );
len = size( T, 1 );

%% start Fit
for job_number = 1: len
    
    dataset   = T.dataset(job_number);
    roi       = T.roiNum(job_number);
    model_idx = T.modelNum(job_number);
    model     = T.modelLoader{job_number};

    % set the save info 
    save_temp = fullfile( save_address, 'temp');
    if ~exist(save_temp, 'dir'), mkdir(save_temp); end
    save_info.dir = save_temp;
    save_info.roi = roi;
    save_info.model_idx = model_idx;
    save_info.dataset = dataset;
    %save_info.start_idx = start_idx;

    % display information to keep track
    display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
    disp( display )

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
            model.fit( model, E, weight_E, BOLD_target, verbose , cross_valid);
        
    else 
        % fit the data without cross validation: knock-1-out, don't show the fit
        [BOLD_pred, params, Rsquare, model] = ...
            model.fit( model, E, BOLD_target, verbose, cross_valid, save_info);
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



