
clear; close all;clc

%% Set up the dataset and the models we are going to test

% The default datasets and model types are shown below, but runing SOC
% model is really time consuming and the model is not the model we focus
% on, so here, we can fit partially. Use chooseData to fit partilly.

%alldataset = {'Ca69_v1' , 'Ca05_v1' , 'K1_v1' , 'K2_v1' , 'Ca69_v2' , 'Ca05_v2' , 'K1_v2' , 'K2_v2' , 'Ca69_v3' , 'Ca05_v3' , 'K1_v3' , 'K2_v3'};
%allmodel = {'contrast' ,  'normStd' , 'normVar' , 'normPower' , 'SOC'};
%alltype = {'orientation' , 'orientation' , 'orientation' , 'orientation' , 'space'};

% Function to choose dataset and model. the first value is to choose ROI,
% choose from {'all' , 'v1' , 'v2', 'v3'}
% Choose from {'fit_all' , 'fit_ori', 'fit_spa'}
[ alldataset ,  allmodel , alltype] = chooseData( 'all' , 'fit_all' );

% How many random start points.
fittime  = 5;

%% Load E_xy

%  In model under orientation category, loading data is a built-in
%  function, which means we do not need to load the data by ourselves.
%  However, loading E_xy data takes a lot of time, so here we load E_xy
%  data first and then introduce them as a new data.

E_xy = cell(1,4);
for ii = 1:4
    fname = sprintf('E_xy_%02d.mat', ii);
    tmp = load(fname, 'E_xy');
    E_xy{ii} = tmp.E_xy; clear tmp;
end



%% Predict the BOLD response of given stimuli

% Create empty matrix

save_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% 1: size(alldataset , 2)
tmp = str2num(getenv('SLURM_ARRAY_TASK_ID'));

data_index = tmp;

para_summary_all = zeros(3 , 50 , size(allmodel , 2)); % 3(w or c or none) x n_stimuli x n_model
pred_summary_all = zeros(50 , size(allmodel , 2)); %  n_stimuli x n_model
Rsqu_summary_all = zeros(size(allmodel , 2));  %  n_model

% Select the dataset and show
which_data = alldataset{data_index};

for model_index = 1:size(allmodel , 2) % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
       
    % Select the model and show
    which_model = allmodel{model_index};
    
    % Select the type of the model
    which_type = alltype{model_index};
    
   
    
    if model_index ~= 5
        
        % Make predictions
        [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type , fittime);
        
    else
        
        E_op = E_xy{which_data(1)};
        load(sprintf('dataset%02d.mat', which_data(1)));
        v_mean_op = v_mean(which_data(2) , : );
        
        %  Treat the dataset as if it is a new data
        which_data = 'new';
        
        % generate a disk to prevent edge effect
        [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4) );
        
        % Make the prediction
        [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type, fittime, v_mean_op , E_op , w_d);
        
    end
    
    % Ensure the dimension matches
    if ~isequal( size(para_summary_all , 1) , size(parameters,1))
        parameters = parameters';
    end
    if ~isequal( size(pred_summary_all , 1) , size(BOLD_prediction,1))
        BOLD_prediction = BOLD_prediction';
    end
    
    % Parameters Estimation
    para_summary_all( : , 1:size(BOLD_prediction, 1) , model_index) = parameters;
    % BOLD predictions Prediction
    pred_summary_all(1:size(BOLD_prediction, 1) , model_index) = BOLD_prediction;
    % Rsquare Summary
    Rsqu_summary_all( model_index) = Rsquare;
    
    
    % Save the results
    save(fullfile(save_address , sprintf('para_summary_all_%d_%d.mat',which_data(1), which_data(2) )) , 'para_summary_all');
    save(fullfile(save_address , sprintf('pred_summary_all_%d_%d.mat',which_data(1), which_data(2) )) , 'pred_summary_all');
    save(fullfile(save_address , sprintf('Rsqu_summary_all_%d_%d.mat',which_data(1), which_data(2) )) , 'Rsqu_summary_all');
    
end


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



