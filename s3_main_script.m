%% Set up the dataset and the models we are going to test

% The default datasets and model types are shown below, but runing SOC
% model is really time consuming and the model is not the model we focus
% on, so here, we can fit partially. Use chooseData to fit partilly.

% Function to choose dataset and model. the first value is to choose ROI,
% choose from {'all' , 'v1' , 'v2', 'v3'}
% Choose from {'fit_all' , 'fit_ori', 'fit_spa'}
[ alldataset ,  allmodel , alltype] = chooseData( 'all' , 'fit_all' );
assert(isequal(length(allmodel), length(alltype)));

numdatasets = length(alldataset);
nummodels   = length(allmodel);

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix

save_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

hcp_job_number = str2num(getenv('SLURM_ARRAY_TASK_ID'));

data_idx    = mod(hcp_job_number-1, numdatasets)+1;
which_data  = alldataset{data_idx};

model_index = mod(hcp_job_number-1, nummodels)+1;
which_model = allmodel{model_index};
which_type  = alltype{model_index};


if model_index ~= 5
    
    % Make predictions
    [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type , fittime);
    
else
    
    % Load E_xy
    
    %  In model under orientation category, loading data is a built-in
    %  function, which means we do not need to load the data by ourselves.
    %  However, loading E_xy data takes a lot of time, so here we load E_xy
    %  data first and then introduce them as a new data.
        
    fname = sprintf('E_xy_%02d.mat', which_data(1));
    tmp = load(fname, 'E_xy');
    E_op = tmp.E_xy; clear tmp;
    
    load(sprintf('dataset%02d.mat', which_data(1)));
    v_mean_op = v_mean(which_data(2) , : );
        
    % generate a disk to prevent edge effect
    [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4) );
    
    % Make the prediction
    [ parameters , BOLD_prediction , Rsquare ]=cross_validation('new', which_model, which_type, fittime, v_mean_op , E_op , w_d);
    
end


% Save the results
save(fullfile(save_address , sprintf('parameters_data-%d_roi-%d_model-%d.mat',which_data(1), which_data(2), model_index )) , 'parameters');
save(fullfile(save_address , sprintf('prediction_data-%d_roi-%d_model-%d.mat',which_data(1), which_data(2), model_index )) , 'BOLD_prediction');
save(fullfile(save_address , sprintf('Rsquare_data-%d_roi-%d_model-%d.mat',   which_data(1), which_data(2), model_index )) , 'Rsquare');

return
%


