%% Set up the dataset and the models we are going to test
%
% % For running on HPC, execute 
%       sbatch  run.sh
% % where run2.sh is an executable file containing the following text
%
% #! /bin/bash
% #SBATCH --job-name=StdModel2
% #SBATCH -a 1-72 # these numbers are read in to SLURM_ARRAY_TASK_ID 
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



T = chooseData('all');

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix
[ currPath, prevPath ] = stdnormRootPath();
save_address = fullfile(currPath, 'Data', 'fitResults', 'Two main stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

hpc_job_number = str2num(getenv('SLURM_ARRAY_TASK_ID'));

if isempty(hpc_job_number), hpc_job_number = 57; end

dataset     = T.dataset(hpc_job_number);
roi         = T.roiNum(hpc_job_number);
which_model = T.modelName{hpc_job_number};
which_type  = T.typeName{hpc_job_number};
model_idx   = T.modelNum(hpc_job_number);

disp(T(hpc_job_number,:));

switch dataset
    case {1, 2}
        which_stim = 1:10;
    case {3, 4}
        which_stim = 31:39;
end

if strcmp( which_type, 'orientation' )
    
    fname = sprintf('E_ori_%02d.mat', dataset);
    tmp = load(fname, 'E_ori');
    E_op = tmp.E_ori(:,:, which_stim); clear tmp;
    
    load(sprintf('dataset%02d.mat', dataset), 'v_mean');
    v_mean_op = v_mean(roi , which_stim );
    
    w_d = 0;
    
    [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d);

else
    
     % Load E_xy
    
    %  In model under orientation category, loading data is a built-in
    %  function, which means we do not need to load the data by ourselves.
    %  However, loading E_xy data takes a lot of time, so here we load E_xy
    %  data first and then introduce them as a new data.
    
    fname = sprintf('E_xy_%02d.mat', dataset);
    tmp = load(fname, 'E_xy');
    E_op = tmp.E_xy(:,:,:,:,which_stim); clear tmp;
    
    load(sprintf('dataset%02d.mat', dataset), 'v_mean');
    v_mean_op = v_mean(roi , which_stim );
    
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
            weight_E = tmp.weight_E(:,:,:,:,which_stim); clear tmp;
            
            
            [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d, weight_E );
    end
    
   
end

% Save the results
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'parameters');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',dataset, roi, model_idx )) , 'BOLD_prediction');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   dataset, roi, model_idx )) , 'Rsquare');

return
%


