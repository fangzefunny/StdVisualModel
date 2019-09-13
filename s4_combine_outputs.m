%% Table 1 + Table S1 + Table S2: R Square

T= chooseData();



nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli  = 50;
numparams   = 3;

load_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'All stimulus classes');

para_summary_all = NaN(numstimuli,numparams,nummodels,numdatasets, numrois);
pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
Rsqu_summary_all = NaN(nummodels,numdatasets, numrois);

for dataset = 1:numdatasets
    for roi = 1:numrois
        for model = 1:nummodels
            
            fname = sprintf('parameters_data-%d_roi-%d_model-%d.mat', ...
                dataset, roi, model);
            load(fullfile(load_address, fname), 'parameters');
            
            para_summary_all( 1:size(parameters,1) , :, model , dataset, roi) = parameters;
            
            fname = sprintf('Rsquare_data-%d_roi-%d_model-%d.mat', ...
                dataset, roi, model);
            load(fullfile(load_address, fname), 'Rsquare');
            
            Rsqu_summary_all(model, dataset, roi) = Rsquare;
            
            fname = sprintf('prediction_data-%d_roi-%d_model-%d.mat', ...
                dataset, roi, model);
            load(fullfile(load_address, fname), 'BOLD_prediction');
            pred_summary_all( 1:size(BOLD_prediction,2) , model , dataset, roi) = BOLD_prediction';
        end
    end
end

%%

% V1
showRsquare_v1 = Rsqu_summary_all(: , :, 1);

% V2
showRsquare_v2 = Rsqu_summary_all(: , :, 2);

% V3
showRsquare_v3 = Rsqu_summary_all(: , :, 3 );


%% Table S4 + Table S5 + Table S6: Estimated parameters

for dataset = 1:numdatasets
    for roi = 1:numrois
        for model_index = 1:6 % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
            
            % all models except contrast model have three parameters.
            if model_index ~= 1
                lambda_set = para_summary_all(: , 1, model_index , dataset, roi); % type of parameter x stimuli x which_model x which_data
            else
                lambda_set = NaN( size(para_summary_all , 1), 1 , 1 , 1, 1);
            end
            
            g_set = para_summary_all( :, 2 , model_index , dataset, roi); % type of parameter x stimuli x which_model x which_data
            n_set = para_summary_all( :, 3, model_index , dataset, roi); % type of parameter x stimuli x which_model x which_data
            
            % valid vector: not all dataset have 50 valid stimuli, some have 48
            % , and the other have 39
            
            if dataset == 1
                valid_vector = 1:50; %Ca69
            elseif dataset ==2
                valid_vector = 1:48; % Ca05
            else
                valid_vector = 1:39; %K1 & K2
            end
            
            mean_para = [mean(lambda_set(valid_vector)) , mean(g_set(valid_vector)) , mean(n_set(valid_vector))];
            std_para =[ std(lambda_set(valid_vector)) , std(g_set(valid_vector)) , std(n_set(valid_vector)) ];
            
            
            showPara_mean( : , model_index , dataset, roi ) =  mean_para';
            showPara_std( : , model_index , dataset, roi ) = std_para';
            
        end
    end
end

% s4_combine_outputs

%% Plot the result (Figure S)
% Here we choose results from contrast model, std model, SOC model for ploting
disp(T.modelName(1:6))

modelsToPlot = [1 5]% [1:6];
legend_name = {'data'};
for ii =1 :length(modelsToPlot)
    legend_name = [legend_name T.modelName{modelsToPlot(ii)}];
end


for dataset = 1%:numdatasets
    
    figure(dataset); clf
    set(gcf, 'Position',  [273   630   1000   500]);
    for roi = 1:numrois
        
        subplot(3,1,roi)
        % Plot
        plot_BOLD(dataset, roi , pred_summary_all(: ,  modelsToPlot, dataset, roi) , legend_name);
       % plot_BOLD(dataset, roi , pred_summary_all(: , :, dataset, roi) , legend_name);
        % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
        
        title(sprintf('V%d, Dataset %d', roi, dataset));
    end
    
    hgexport(gcf, sprintf('~/Desktop/allstims_dataset_%d.eps', dataset))
end

