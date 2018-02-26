
clear all; close all;clc
%% Add paths

addpath(genpath(fullfile(pwd,'ROImean')));
addpath(genpath(fullfile(pwd,'E')));

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
load E_xy_69
load E_xy_05
load E_xy_K

E_xy = {E_xy_69 , E_xy_05 , E_xy_K};

% Clear to save space
clear E_xy_69
clear E_xy_05
clear E_xy_K

%% Predict the BOLD response of given stimuli

% Create empty matrix
para_summary_all = zeros(3 , 50 , size(allmodel , 2) , size(alldataset , 2)); % 3(w or c or none) x n_stimuli x n_model x n_data
pred_summary_all = zeros(50 , size(allmodel , 2) , size(alldataset , 2)); %  n_stimuli x n_model x n_data
Rsqu_summary_all =  zeros(size(allmodel , 2) , size(alldataset , 2));  %  n_model x n_data


for data_index = 1: size(alldataset , 2) 
    
    for model_index = 1:size(allmodel , 2) % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
        
        % Select the model and show 
        which_model = allmodel{model_index}
        
        % Select the type of the model
        which_type = alltype{model_index}
        
        % Select the dataset and show 
        which_data = alldataset{data_index}
        
        if model_index ~= 5

            % Make predictions
            [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type , fittime);
            
        else
            
            switch which_data
                
                case {'Ca69_v1', 'Ca69_v2' , 'Ca69_v3' }
                    E_op = E_xy{1};
                    load v_mean_69
                    switch which_data
                        case 'Ca69_v1'
                            v_mean_op = v_mean_69(1 , : );
                        case 'Ca69_v2'
                            v_mean_op = v_mean_69(2 , : );
                        case 'Ca69_v3'
                            v_mean_op = v_mean_69(3 , : );
                    end
                    
                case {'Ca05_v1', 'Ca05_v2' , 'Ca05_v3' }
                    E_op = E_xy{2}; 
                    load v_mean_05;
                    switch which_data
                        case 'Ca05_v1'
                            v_mean_op = v_mean_05(1 , : );
                        case 'Ca05_v2'
                            v_mean_op = v_mean_05(2 , : );
                        case 'Ca05_v3'
                            v_mean_op = v_mean_05(3 , : );
                    end
                    
                otherwise
                    E_op = E_xy{3};     
                    load v_mean_K1;
                    load v_mean_K2;
                    switch which_data
                        case 'K1_v1'
                            v_mean_op = v_mean_K1(1 , : );
                        case 'K1_v2'
                            v_mean_op = v_mean_K1(2 , : );
                        case 'K1_v3'
                            v_mean_op = v_mean_K1(3 , : );
                        case 'K2_v1'
                            v_mean_op = v_mean_K2( 1 , : );
                        case 'K2_v2'
                            v_mean_op = v_mean_K2(2 , : );
                        case 'K2_v3'
                            v_mean_op = v_mean_K2(3 , : );
                    end
            end
            
            % Treat the dataset asif it is a new data
            which_data = 'new';
            
            % generate a disk to prevent edge effect
            [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4) );
            
            % Make the prediction 
            [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type, fittime, v_mean_op , E_op , w_d);
            
        end
        
        % Ensure the dimension matches
        if isequal( size(para_summary_all , 1) , size(parameters)) == 0
            parameters = parameters';
        end
        if isequal( size(pred_summary_all , 1) , size(BOLD_prediction)) == 0
            BOLD_prediction = BOLD_prediction';
        end

        % Parameters Estimation
        para_summary_all( : , 1:size(BOLD_prediction, 2) , model_index , data_index) = parameters;
        % BOLD predictions Prediction
        pred_summary_all(1:size(BOLD_prediction, 2) , model_index , data_index) = BOLD_prediction;
        % Rsquare Summary
        Rsqu_summary_all( model_index , data_index) = Rsquare;
        
    end
    
end

%% Save the results
save_address = fullfile(pwd, 'fitResults' );

save([save_address , '\para_summary_all'] , 'para_summary_all');
save([save_address , '\pred_summary_all'] , 'pred_summary_all');
save([save_address , '\Rsqu_summary_all'] , 'Rsqu_summary_all');

%% Table 1 + Table S1 + Table S2: R Square

% V1
showRsquare_v1 = Rsqu_summary_all(: , 1:4)

% V2
showRsquare_v2 = Rsqu_summary_all(: , 5:8 )

% V3
showRsquare_v3 = Rsqu_summary_all(: , 9:12 )


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

addpath(genpath(fullfile(pwd,'plot')));

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



