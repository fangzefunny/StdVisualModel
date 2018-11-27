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
%% Table 1 + Table S1 + Table S2: R Square

% V1
showRsquare_v1 = Rsqu_summary_all(: , 1:4);

% V2
showRsquare_v2 = Rsqu_summary_all(: , 5:8 );

% V3
showRsquare_v3 = Rsqu_summary_all(: , 9:12 );


%% Table S3 + Table S4 + Table S5: Estimated parameters

for data_index = 1: size(alldataset , 2) % dataset: (1-4: v1, 5-8: v2 , 9-12:v3)
    
    for model_index = 1:5 % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
        
        % all models except contrast model have three parameters.
        if model_index ~= 1
            lambda_set = para_summary_all( 1 , : , model_index , data_index); % type of parameter x stimuli x which_model x which_data
        else
            lambda_set = NaN( 1 , size(para_summary_all , 2) , 1 , 1 );
        end
        
        g_set = para_summary_all( 2 , : , model_index , data_index); % type of parameter x stimuli x which_model x which_data
        n_set = para_summary_all( 3 , : , model_index , data_index); % type of parameter x stimuli x which_model x which_data
        
        % valid vector: not all dataset have 50 valid stimuli, some have 48
        % , and the other have 39
        
        data_type = mod( data_index , 4 );
        
        if data_type == 1
            valid_vector = 1:50; %Ca69
        elseif data_type ==2
            valid_vector = 1:48; % Ca05
        else
            valid_vector = 1:39; %K1 & K2
        end
        
        mean_para = [mean(lambda_set(valid_vector)) , mean(g_set(valid_vector)) , mean(n_set(valid_vector))];
        std_para =[ std(lambda_set(valid_vector)) , std(g_set(valid_vector)) , std(n_set(valid_vector)) ];
        
        
        showPara_mean( : , model_index , data_index ) =  mean_para';
        showPara_std( : , model_index , data_index ) = std_para';
        
    end
end



%% Plot the result (Figure S)
% Here we choose results from contrast model, std model, SOC model for ploting

legend_name = {'data', 'contrast' , 'normStd' , 'normVar' , 'normPower' , 'SOC'};

for data_index = 1: size(alldataset , 2)
    
    
    % Select the dataset
    which_data = alldataset{data_index};
    
    % Plot
    plot_BOLD(which_data , pred_summary_all(: , : , data_index) , legend_name);
    % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
    
    switch data_index
        case { 1 , 2 , 3 , 4 }
            title('v1')
        case { 5 , 6 , 7 , 8 }
            title('v2')
        case { 9 , 10 , 11 , 12 }
            title('v3')
    end
    
end



