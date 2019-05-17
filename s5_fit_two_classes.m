%% Set up the dataset and the models we are going to test
%
% % For running on HPC, execute 
%       sbatch  run.sh
% % where run2.sh is an executable file containing the following text
%
% #! /bin/bash
% #SBATCH --job-name=StdModel2
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
% s5_fit_two_classes
% EOF



% The default datasets and model types are shown below, but runing SOC
% model is really time consuming and the model is not the model we focus
% on, so here, we can fit partially. Use chooseData to fit partilly.

% Function to choose dataset and model. the first value is to choose ROI,
% choose from {'all' , 'v1' , 'v2', 'v3'}
% Choose from {'fit_all' , 'fit_ori', 'fit_spa'}
[alldataset ,  allmodel , alltype] = chooseData( 'all' , 'fit_all' );
assert(isequal(length(allmodel), length(alltype)));

numdatasets = length(alldataset);
nummodels   = length(allmodel);

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix

save_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'Two main stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

hpc_job_number = 1; %str2num(getenv('SLURM_ARRAY_TASK_ID'));
data_idx    = mod(hpc_job_number-1, numdatasets)+1;
which_data  = alldataset{data_idx};
dataset     = which_data(1);
roi         = which_data(2);
model_index = mod(hpc_job_number-1, nummodels)+1;
which_model = allmodel{model_index};
which_type  = alltype{model_index};

switch dataset
    case {1, 2}
        which_stim = 1:10;
    case {3, 4}
        which_stim = 31:39;
end

if model_index ~= 5
    
    fname = sprintf('E_ori_%02d.mat', dataset);
    tmp = load(fname, 'E_ori');
    E_op = tmp.E_ori(:,:, which_stim); clear tmp;
    
    load(sprintf('dataset%02d.mat', dataset), 'v_mean');
    v_mean_op = v_mean(roi , which_stim );
    
    w_d = 0;
    
    
else
    
    % Load E_xy
    
    %  In model under orientation category, loading data is a built-in
    %  function, which means we do not need to load the data by ourselves.
    %  However, loading E_xy data takes a lot of time, so here we load E_xy
    %  data first and then introduce them as a new data.
        
    fname = sprintf('E_xy_%02d.mat', dataset);
    tmp = load(fname, 'E_xy');
    E_op = tmp.E_xy(:,:, which_stim); clear tmp;
    
    load(sprintf('dataset%02d.mat', dataset), 'v_mean');
    v_mean_op = v_mean(roi ,  which_stim );
        
    % generate a disk to prevent edge effect
    [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4) );
        
end

[ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d);

% Save the results
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_index )) , 'parameters');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_index )) , 'BOLD_prediction');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_index )) , 'Rsquare');

return
%


