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



% The default datasets and model types are shown below, but runing SOC
% model is really time consuming and the model is not the model we focus
% on, so here, we can fit partially. Use chooseData to fit partilly.

% Function to choose dataset and model. the first value is to choose ROI,
% choose from {'all' , 'v1' , 'v2', 'v3'}
% Choose from {'fit_all' , 'fit_ori', 'fit_spa'}
[alldataset ,  allmodel , alltype] = chooseData( 'all' , 'fit_all' );
%assert(isequal(length(allmodel), length(alltype)));

numdatasets = length(alldataset);
nummodels   = length(allmodel);

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix

save_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

hpc_job_number = str2num(getenv('SLURM_ARRAY_TASK_ID'));
hpc_job_number =   1;
data_idx    = mod(hpc_job_number-1, numdatasets)+1;
which_data  = alldataset{data_idx};
dataset     = which_data(1);
roi         = which_data(2);
model_index = mod(hpc_job_number-1, nummodels)+1;
which_model = allmodel{model_index};
which_type  = alltype{model_index};


if strcmp( which_type, 'orientation' ) == 1
    
    % Make predictions
    [ parameters , BOLD_prediction , Rsquare ]=cross_validation(dataset, roi , which_model, which_type , fittime);
    
elseif strcmp( which_type, 'space') == 1
    
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
    [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4) );
    
    % Make the prediction
    switch which_model
        case 'SOC'
            
            [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d);
            
        case 'ori_surround'
            
            % Load weight_E
            fname = sprintf('weight_E_%02d.mat', dataset);
            tmp = load(fname, 'weight_E');
            weight_E = tmp.weight_E; clear tmp;
            
            %%%%%%%%% Testing the 10 target stimuli%%%%%%%%
            %E_op = E_op( :, :, :, :, 1:10 );
            %weight_E  = weight_E( :, :, :, :, 1:10 );
            %v_mean_op = v_mean_op( 1:10 );
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', [], which_model, which_type, fittime, v_mean_op , E_op , w_d, weight_E );
    end
end


% Save the results
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',which_data(1), which_data(2), model_index )) , 'parameters');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',which_data(1), which_data(2), model_index )) , 'BOLD_prediction');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   which_data(1), which_data(2), model_index )) , 'Rsquare');

return
%


