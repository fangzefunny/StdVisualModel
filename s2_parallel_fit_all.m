%% Set up the dataset and the models we are going to test
%
% % For running on HPC, execute
%       sbatch  run.sh
% % where run.sh is an executable file containing the following text
%
% #! /bin/bash
% #SBATCH --job-name=StdModel
% #SBATCH -a 1-48 # these numbers are read in to SLURM_ARRAY_TASK_ID
% #SBATCH --nodes=1
% #SBATCH --cpus-per-task=4
% #SBATCH --mem=16g
% #SBATCH --time=08:00:00
% #SBATCH --output=/scratch/jaw288/StdVisualModel/Data/HPC/out_%x-%a.txt
% #SBATCH --error=/scratch/jaw288/StdVisualModel/Data/HPC/error_%x-%a.txt
%
% module load matlab/2019b
%
% matlab <<EOF
% addpath(genpath('~/toolboxes'));
% s2_parallel_fit_all
% EOF

%% hyperparameter: each time, we only need to edit this section !! 

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'all';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how manoy initialization. value space: Integer
data_folder    = 'noCross';  % save in which folder. value space: 'noCross', .....
cross_valid      = 'one';           % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_model = 'all';          % choose some preset data 

%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot_tools' )))

 %% generate save address and  choose data 

% save address 
save_address = fullfile(prevPath, 'Data', data_folder, target,  optimizer);
if ~exist(save_address, 'dir'), mkdir(save_address); end

% choose data as if we are doing parallel computing 
T      = chooseData( choose_model, optimizer, fittime );
len = size( T, 1 );

%% start Fit

hpc_job_number = str2num(getenv('SLURM_ARRAY_TASK_ID'));

if isempty(hpc_job_number), hpc_job_number = 5; end

dataset          = T.dataset(hpc_job_number);
roi                   = T.roiNum(hpc_job_number);
model_idx   = T.modelNum(hpc_job_number);
model           = T.modelLoader{model_idx};

disp(T(hpc_job_number, :));

% display information to keep track
display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
disp( display )

% load training label
BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi );

% load the input stimuli
switch model.model_type
    case 'orientation'
        which_obj ='E_ori';
    case 'space'
        which_obj = 'E_xy';
end
E = dataloader( prevPath, which_obj, target, dataset, roi, 'old' );

if strcmp( model.legend, 'oriSurround')
    disp( 'ori_surround')
    
    % gain weight E
    weight_E = dataloader( prevPath, 'weight_E', target, dataset, roi );
    
    % fit the data without cross validation: knock-1-out, don't show the fit
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit( model, E, weight_E, BOLD_target, 'off', cross_valid);
    
elseif strcmp( model.legend, 'SOC1')
    disp( 'soc1')
    
    % gain E_mean
    E_mean = dataloader( prevPath, 'E_mean', target, dataset, roi );
    
    % fit the data without cross validation: knock-1-out, don't show the fit
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit( model, E, E_mean, BOLD_target, 'off', cross_valid);
    
else
    
    % fit the data without cross validation: knock-1-out, don't show the fit
    [BOLD_pred, params, Rsquare, model] = ...
        model.fit( model, E, BOLD_target, 'off', cross_valid);
end

if strcmp( cross_valid, 'one')
    loss_log = model.loss_log;
end

% save data
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'params');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'BOLD_pred');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'Rsquare');
if strcmp( cross_valid, 'one')
    save(fullfile(save_address , sprintf('loss_log_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'loss_log');
end







