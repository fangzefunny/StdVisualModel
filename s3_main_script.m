
clear all; close all;clc

%% Set up the dataset and the models we are going to test

alldataset = {'Ca69_v1' , 'Ca05_v1' , 'K1_v1' , 'K2_v1' , 'Ca69_v2' , 'Ca05_v2' , 'K1_v2' , 'K2_v2' , 'Ca69_v3' , 'Ca05_v3' , 'K1_v3' , 'K2_v3'};
allmodel = {'contrast' ,  'normStd' , 'normVar' , 'normPower' , 'SOC'}
alltype = {'orientation' , 'orientation' , 'orientation' , 'orientation' , 'space'};

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix
para_summary_all = zeros(3 , 50 , size(allmodel , 2) , size(alldataset , 2)); % 3(w or c or none) x n_stimuli x n_model x n_data
pred_summary_all = zeros(50 , size(allmodel , 2) , size(alldataset , 2)); %  n_stimuli x n_model x n_data
Rsqu_summary_all =  zeros(size(allmodel , 2) , size(alldataset , 2));  %  n_model x n_data


for data_index = 1: size(alldataset , 2)
    
    % Select the dataset
    which_data = alldataset{data_index}
    
    for model_index = 1:size(allmodel , 2)
        
        % Select the model
        which_model = allmodel{model_index}
        
        % Select the type of the model
        which_type = alltype{model_index};
        
        % Make predictions
        [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type , fittime);
        
        % Parameters Estimation
        para_summary_all( : , 1:size(BOLD_prediction, 2) , model_index , data_index) = parameters';
        % BOLD predictions Prediction
        pred_summary_all(1:size(BOLD_prediction, 2) , model_index , data_index) = BOLD_prediction;
        % Rsquare Summary
        Rsqu_summary_all( model_index , data_index) = Rsquare;
        
    end
    
end

%% Save the results
save_address = fullfile(pwd, 'results' );

save([save_address , '\para_summary_all'] , 'para_summary_all');
save([save_address , '\pred_summary_all'] , 'pred_summary_all');
save([save_address , '\Rsqu_summary_all'] , 'Rsqu_summary_all');

%% Table 1: R Square

% V1
showRsquare_v1 = Rsqu_summary_all(: , 1:4) 

% V2
showRsquare_v2 = Rsqu_summary_all(: , 5:8 ) 

% V3
showRsquare_v3 = Rsqu_summary_all(: , 9:12 ) 


%% Table 2: Estimated parameters

for data_index = 1: size(alldataset , 2) % dataset: (1-4: v1, 5-8: v2 , 9-12:v3)
    
    for model_index  = 1:5 % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
        
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
        
        data_type = mod( data_index , 4 ) 
        
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

addpath(genpath(fullfile(pwd,'plot')));

legend_name = {'data', 'contrast' , 'normStd' , 'SOC'};

for data_index = 1:size(alldataset , 2)
    
    % Select the dataset
    which_data = alldataset{data_index};
    
    % Plot
    plot_BOLD(which_data , pred_summary_all(: , [1 , 2 , 5]  , data_index) , legend_name); 
    % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC) 
    
    switch data_index
        case { 1 , 2 , 3 , 4 }
            title('V1')
        case { 5 , 6 , 7 , 8 }
            title('V2')
        case { 9 , 10 , 11 , 12 }
            title('V3')
    end
    
end



