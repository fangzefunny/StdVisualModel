%% Table ??: R square

T= chooseData();



nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli  = 10;
numparams   = 3;

load_address = fullfile(stdnormRootPath, 'Data', 'fitResults', 'Two main stimulus classes');

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


%% Table ??: Estimated parameters

for dataset = 1:numdatasets
    for roi = 1:numrois
        for model_index = 1:5 % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
            
            % all models except contrast model have three parameters.
            if model_index ~= 1
                lambda_set = para_summary_all(: , 1, model_index , dataset, roi); % type of parameter x stimuli x which_model x which_data
            else
                lambda_set = NaN( size(para_summary_all , 1), 1 , 1 , 1, 1);
            end
            
            g_set = para_summary_all( :, 2 , model_index , dataset, roi); % type of parameter x stimuli x which_model x which_data
            n_set = para_summary_all( :, 3, model_index , dataset, roi); % type of parameter x stimuli x which_model x which_data
           
            
            mean_para = [nanmean(lambda_set) , nanmean(g_set) , nanmean(n_set)];
            std_para =[ std(lambda_set, 'omitnan') , std(g_set, 'omitnan') , std(n_set, 'omitnan') ];
            
            
            showPara_mean( : , model_index , dataset, roi ) =  mean_para';
            showPara_std( : , model_index , dataset, roi ) = std_para';
            
        end
    end
end

% s4_combine_outputs

%% Plot the result (Figure S)
% Here we choose results from contrast model, std model, SOC model for ploting

modelsToPlot = [1 3];% [1:6];
legend_name = {'patterns' 'gratings'};
for ii =1 :length(modelsToPlot)
    legend_name = [legend_name T.modelName{modelsToPlot(ii)}];
end
figure;set(gcf, 'Position', [1 1 800 1000])

for dataset = 1:4%:numdatasets
    switch dataset
        case {1, 2}
            which_stim = 1:10;
        case {3, 4}
            which_stim = 31:39;
    end
    for roi = 1:numrois

        load(sprintf('dataset%02d.mat', dataset), 'v_mean');
        v_mean_op = v_mean(roi ,  which_stim );
        
        subplot(4,3, roi+ (dataset-1)*3);
        %subplot(1,3, roi);
        % Plot
        %plot_BOLD(sprintf('%d_target', dataset), [], pred_summary_all(: , : , dataset, roi), legend_name , v_mean_op)
        plot_BOLD(sprintf('%d_target', dataset), [], pred_summary_all(: , modelsToPlot , dataset, roi), legend_name , v_mean_op)
        % model: (1: contrast, 2:std, 3: var, 4: power, 5:SOC)
        
        title(sprintf('V%d, Dataset %d', roi, dataset));
    end
    
    
end

