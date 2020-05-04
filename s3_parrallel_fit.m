%% Set up the dataset and the models we are going to test
%
% % For running on HPC, execute
%       sbatch  run.sh
% % where run.sh is an executable file containing the following text
%
% #! /bin/bash
% #SBATCH --job-name=StdModel
% #SBATCH -a 6,18,30,42,54 # these numbers are read in to SLURM_ARRAY_TASK_ID
% #SBATCH --nodes=1
% #SBATCH --cpus-per-task=4
% #SBATCH --mem=16g
% #SBATCH --time=08:00:00
% #SBATCH --output=/scratch/jaw288/StdVisualModel/Data/HPC/out_%x-%a.txt
% #SBATCH --error=/scratch/jaw288/StdVisualModel/Data/HPC/error_%x-%a.txt
%
% module load matlab/2018a
%
% matlab <<EOF
% addpath(genpath('~/toolboxes'));
% s3_main_script
% EOF


T = chooseData( 'orientation' );

%% Predict the BOLD respose of the given stimuli

% Create empty matrix
[ currPath, prevPath ] = stdnormRootPath();
save_dir = fullfile( currPath, 'Data', 'new', 'allstimClass' );
if ~exist( save_dir, 'dir' ), mkdir( save_dir ); end 

hpc_job_number = str2num(getenv('SLURM_ARRAY_TASK_ID'));

if isempty(hpc_job_number), hpc_job_number = 5; end

dataset     = T.dataset(hpc_job_number);
roi         = T.roiNum(hpc_job_number);
which_model = T.modelName{hpc_job_number};
model_idx   = T.modelNum(hpc_job_number);
model = T.modelLoader{model_idx};

disp(T(hpc_job_number,:));

% display information to keep track
display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
disp( display )

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

% fit the data with cross validation: knock-1-out, don't show the fit 
[BOLD_pred, params, Rsquare, model] = ...
    model.fit( model, E, BOLD_target, 'off', 'cross_valid' );

% save data
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'params');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'BOLD_pred');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'Rsquare');


