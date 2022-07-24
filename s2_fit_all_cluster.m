%% Set up the dataset and the models we are going to test
% For running on HPC, execute
%       sbatch  hpc_solve_models.sh

%% Parse the hyperparameters
if ~exist('doCross', 'var'), doCross = true; end
if ~exist('target', 'var'),  target  = 'all'; end % 'target' or 'All';
if ~exist('start_idx', 'var'), start_idx = 1; end    % what fold in the cross 
                                                        % validation to start
if ~exist('choose_model', 'var'), choose_model = 'more'; end % "all" means model 1-5, "more" means 1-6
switch doCross
    case false
        cross_valid = 'one';            % 'one': not cross validate; 'cross_valid': cross validate
        data_folder  = 'noCross';       % save in which folder. value space: 'noCross', 'Cross'
    case true
        cross_valid  = 'cross_valid';   % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'Cross';         % save in which folder. value space: 'noCross', .....
end

optimizer            = 'fmincon'; % what kind of optimizer,  value space: 'bads', 'fmincon'
fittime              = 40;        % how many initialization. value space: Integer
verbose              = 'off';     % show the fit details? 
%% generate save address and choose data 

% save address 
save_address = fullfile(stdnormRootPath, 'Data', data_folder, target,  optimizer);
if ~exist(save_address, 'dir'), mkdir(save_address); end

% create jobs 
T = chooseData(choose_model, optimizer, fittime);

%% Start fit

% assign job 
hpc_job_number = str2double(getenv('SLURM_ARRAY_TASK_ID'));
if isnan(hpc_job_number), hpc_job_number = 4; end
dataset   = T.dataset(hpc_job_number);
roi       = T.roiNum(hpc_job_number);
model_idx = T.modelNum(hpc_job_number);
model     = T.modelLoader{hpc_job_number};

% set the save info, this helps in
% continuing job in the broken pipe 
save_temp = fullfile(save_address, 'temp');
if ~exist(save_temp, 'dir'), mkdir(save_temp); end
save_info.dir       = save_temp;
save_info.roi       = roi;
save_info.model_idx = model_idx;
save_info.dataset   = dataset;
save_info.start_idx = start_idx;

% display information to keep track of fitting 
display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str(roi), ' model: ', num2str(model_idx) ];
disp(display)

% load training label
BOLD_target = dataloader(stdnormRootPath, 'BOLD_target', target, dataset, roi);

% load the input E 
switch model.model_type
    case 'orientation'; which_obj = 'E_ori'; % CE, NOA 
    case 'space'      ; which_obj = 'E_xy'; % SOC, OTS
end

E = dataloader(stdnormRootPath, which_obj, target, dataset, roi, 'old');

if strcmp(model.legend, 'oriSurround')
    disp('OTS')

    % gain weight E
    Z = dataloader(stdnormRootPath, 'Z1', target, dataset, roi);
    
    % fit the data without cross validation: knock-1-out
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit(model, E, Z, BOLD_target, verbose , cross_valid, save_info);
    
elseif strcmp(model.legend, 'oriSurround') 
    disp('norm')

    % gain weight E
    Z = dataloader(stdnormRootPath, 'Z2', target, dataset, roi);
    
    % fit the data without cross validation: knock-1-out
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit(model, E, Z, BOLD_target, verbose , cross_valid, save_info);
    
else 
    % fit the data without cross validation: knock-1-out
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit(model, E, BOLD_target, verbose, cross_valid, save_info);
end

if strcmp(cross_valid, 'one')
    loss_log = model.loss_log;
end

% save data
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx)) , 'params');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx)) , 'BOLD_pred');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx))    , 'Rsquare');
if strcmp(cross_valid, 'one')
    save(fullfile(save_address , sprintf('loss_log_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx)) , 'loss_log');
end




