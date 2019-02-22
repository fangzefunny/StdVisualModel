%% Table 1 + Table S1 + Table S2: R Square

load_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'All stimulus classes');

para_summary_all = zeros(50,3,5,12); % stimuli x numparams x models x datasets
for dataset = 1:4
    for roi = 1:3
        for model = 1:5
            
            data_index = (roi-1)*4+dataset;
            
            fname = sprintf('parameters_data-%d_roi-%d_model-%d.mat', ...
                dataset, roi, model);
            load(fullfile(load_address, fname), 'parameters');
            
            para_summary_all( 1:size(parameters,1) , :, model , data_index) = parameters;

        end
    end
end

%%

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


% s4_combine_outputs

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

