%% Focus on two target stimuli

%% Add paths

addpath(genpath(fullfile(pwd,'ROImean')));
addpath(genpath(fullfile(pwd,'E')));

%% Select target stimuli and ROImean

% In Ca 69 and Ca 05, thery are stimuli 1:10. In K Stimuli, they are 31:39
% First, ROImean
load v_mean_69
load v_mean_05
load v_mean_K1
load v_mean_K2
t_mean_05 = v_mean_05(: , 1:10);
t_mean_69 = v_mean_69(: , 1:10);
t_mean_K1 = v_mean_K1(: , 31:39);
t_mean_K2 = v_mean_K2(: , 31:39);

% Then, E_ori
load E_ori_69
load E_ori_05
load E_ori_K

E_ori_t_69 = E_ori_69(: , : , [1:10]);
E_ori_t_05 = E_ori_05(: , : , [1:10]);
E_ori_t_K = E_ori_K( : , : , [31:39]);

% Finally, E_xy
load E_xy_69
load E_xy_05
load E_xy_K

E_xy_t_69 = E_xy_69(: , : , : , [1:10]);
E_xy_t_05 = E_xy_05(: , : , : , [1:10]);
E_xy_t_K = E_xy_K( : , : , : , [31:39]);

% Clear the large file to save space
clear E_xy_69
clear E_xy_05
clear E_xy_K


%% prepare for the fitting

alldataset = {'Ca69_v1' , 'Ca05_v1' , 'K1_v1' , 'K2_v1' , 'Ca69_v2' , 'Ca05_v2' , 'K1_v2' , 'K2_v2' , 'Ca69_v3' , 'Ca05_v3' , 'K1_v3' , 'K2_v3'};
allmodel = {'contrast' ,  'normStd' , 'normVar' , 'normPower' , 'SOC'};
alltype = {'orientation' , 'orientation' , 'orientation' , 'orientation' , 'space'};

fittime = 3;

%% Fitting
% Create empty matrix
para_summary_target = zeros(3 , 10 , size(allmodel , 2) , size(alldataset , 2)); % 3(w or c or none) x n_stimuli x n_model x n_data
pred_summary_target = zeros(10 , size(allmodel , 2) , size(alldataset , 2)); %  n_stimuli x n_model x n_data
Rsqu_summary_target =  zeros(size(allmodel , 2) , size(alldataset , 2));  %  n_model x n_data


for data_index = 1:size(alldataset , 2)
    
    for model_index = 1:size(allmodel , 2)
        
        which_model = allmodel{model_index};
        which_type = alltype{model_index};
        choose_dataset = mod( data_index , 4);
        choose_ROI = floor( (data_index - 1)/4 ) + 1;
        
        switch choose_dataset
            
            % remain = 1, Ca69
            case 1
                t_mean = t_mean_69;
                if model_index ~= 5
                    E_op = E_ori_t_69;
                    w_d = 0;
                else
                    E_op = E_xy_t_69;
                    % generate a disk to prevent edge effect
                    [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4)-1 );
                end
                
                % remain = 2, Ca05
            case 2
                t_mean = t_mean_05;
                if model_index ~= 5
                    E_op = E_ori_t_05;
                    w_d = 0;
                else
                    E_op = E_xy_t_05;
                    % generate a disk to prevent edge effect
                    [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4)-1 );
                end
                
            case {3 , 0}
                if model_index ~= 5
                    E_op = E_ori_t_K;
                    w_d = 0;
                else
                    E_op = E_xy_t_K;
                    % generate a disk to prevent edge effect
                    [ w_d ] = gen_disk( size(E_op , 1) ,  size(E_op , 3)  ,  size(E_op , 4)-1 );
                end
                switch choose_dataset
                    % remain = 3, K1
                    case 3
                        t_mean = t_mean_K1;
                        % remain = 0, K2
                    case 0
                        t_mean = t_mean_K2;
                end
        end
        t_mean_op = t_mean( choose_ROI , : );
        
        % Because we are not going to use the built-in dataset,
        which_data = 'new';
        
        % Make the prediction using cross-validation
        [ parameters , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type, fittime, t_mean_op , E_op , w_d);
        
        % Ensure the dimension matches
        if isequal( size(para_summary_target , 1) , size(parameters , 1)) == 0
            parameters = parameters';
        end
        if isequal( size(pred_summary_target , 1) , size(BOLD_prediction , 1)) == 0
            BOLD_prediction = BOLD_prediction';
        end
        
        % Parameters Estimation
        para_summary_target( : , 1:length(BOLD_prediction) , model_index , data_index) = parameters;
        % BOLD predictions Prediction
        pred_summary_target(1: length(BOLD_prediction) , model_index , data_index) = BOLD_prediction;
        % Rsquare Summary
        Rsqu_summary_target( model_index , data_index) = Rsquare;
    end
end


%% Save the results
save_address = fullfile(pwd, 'fitResults' );

save([save_address , '\Two main stimulus classes\para_summary_target'] , 'para_summary_target');
save([save_address , '\Two main stimulus classes\pred_summary_target'] , 'pred_summary_target');
save([save_address , '\Two main stimulus classes\Rsqu_summary_target'] , 'Rsqu_summary_target');

%% Table 1 + Table S1 + Table S2: R Square

% V1
showRsquare_v1 = Rsqu_summary_target(: , 1:4)

% V2
showRsquare_v2 = Rsqu_summary_target(: , 5:8 )

% V3
showRsquare_v3 = Rsqu_summary_target(: , 9:12 )


%% Table S3 + Table S4 + Table S5: Estimated parameters

for data_index = 1: size(alldataset , 2) % dataset: (1-4: v1, 5-8: v2 , 9-12:v3)
    
    for model_index = 1:5 % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
        
        % all models except contrast model have three parameters.
        if model_index ~= 1
            lambda_set = para_summary_target( 1 , : , model_index , data_index); % type of parameter x stimuli x which_model x which_data
        else
            lambda_set = NaN( 1 , size(para_summary_target , 2) , 1 , 1 );
        end
        
        g_set = para_summary_target( 2 , : , model_index , data_index); % type of parameter x stimuli x which_model x which_data
        n_set = para_summary_target( 3 , : , model_index , data_index); % type of parameter x stimuli x which_model x which_data
        
        % valid vector: not all dataset have 50 valid stimuli, some have 48
        % , and the other have 39
        
        data_type = mod( data_index , 4 );
        
        if (data_type <3) && (data_type > 0 )
            valid_vector = 1:10; %Ca69 & Ca05
        else
            valid_vector = 1:9; %K1 & K2
        end
        
        mean_para = [mean(lambda_set(valid_vector)) , mean(g_set(valid_vector)) , mean(n_set(valid_vector))];
        std_para =[ std(lambda_set(valid_vector)) , std(g_set(valid_vector)) , std(n_set(valid_vector)) ];
        
        
        showPara_mean( : , model_index , data_index ) =  mean_para';
        showPara_std( : , model_index , data_index ) = std_para';
        
    end
end

%% Prepare for the plot.
% In Ca69 and Ca05, 1:5 are pattern group and 6:10 is grating. But in K1
% and K2, 1:5 are grating and 6:9are pattern. Here we can change the
% squence of the result, so it is easy for us to do the plot.
%%

addpath(genpath(fullfile(pwd,'plot')));

legend_name = {'data', 'contrast' , 'normStd' , 'normVar' , 'normPower' , 'SOC'};

for data_index = 1: size(alldataset , 2)
    
    choose_dataset = mod( data_index , 4);
    choose_ROI = floor( (data_index - 1)/4 ) + 1;
    
    switch choose_dataset
        
        % remain = 1, Ca69
        case 1
            t_mean = t_mean_69;
            % remain = 2, Ca05
            % Select the dataset
            which_data = 'Ca69_target';
        case 2
            t_mean = t_mean_05;
            % remain = 3, K1
            which_data = 'Ca05_target';
        case 3
            t_mean = t_mean_K1;
            % remain = 0, K2
            which_data = 'K1_target';
        case 0
            t_mean = t_mean_K2;
            which_data = 'K2_target';
            
    end
    
    t_mean_op = t_mean( choose_ROI , : );

    % Plot
    plot_BOLD(which_data , pred_summary_target(: , : , data_index) , legend_name, t_mean_op);
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
