
clear all; close all;clc

%% Set up the dataset and the models we are going to test

alldataset = {'Ca69_v1' , 'Ca05_v1' , 'K1_v1' , 'K2_v1' , 'Ca69_v2' , 'Ca05_v2' , 'K1_v2' , 'K2_v2' , 'Ca69_v3' , 'Ca05_v3' , 'K1_v3' , 'K2_v3'};
allmodel = {'e' ,  'std' , 'var' , 'power'};%   , 'SOC'
alltype = {'orientation' , 'orientation' , 'orientation' , 'orientation' };% 'space'};

% How many random start points.
fittime  = 5;

%% Predict the BOLD response of given stimuli

% Create empty matrix
para_summary = zeros(3 , 50 , size(allmodel , 2) , size(alldataset , 2));
pred_summary = zeros(50 , size(allmodel , 2) , size(alldataset , 2));
Rsqu_summary =  zeros(1 , size(allmodel , 2) , size(alldataset , 2));


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
        para_summary( : , 1:size(BOLD_prediction, 2) , model_index , data_index) = parameters';
        % BOLD predictions Prediction 
        pred_summary(1:size(BOLD_prediction, 2) , model_index , data_index) = BOLD_prediction;
        % Rsquare Summary 
        Rsqu_summary(: , model_index , data_index) = Rsquare;
               
    end
    
end

%% Save the results 

save('para_summary' , 'para_summary');
save('pred_summary' , 'pred_summary');
save('Rsqu_summary' , 'Rsqu_summary');

%% Table 1: R Square

showRsquare = squeeze( Rsqu_summary )

%% Table 2: Estimated parameters 



%% Plot the result (Figure S)

addpath(genpath(fullfile(pwd,'plot')));

legend_name = {'data', 'Contrast' , 'NormStd' , 'NormVar' , 'NormPower' , 'SOC'};

for data_index = 1: size(alldataset , 2)
     
    % Select the dataset
    which_data = alldataset{data_index};
    
    % Plot 
    plot_BOLD(which_data , pred_summary(: , : , data_index) , legend_name);

end



