
function [] = s4_visualize( fig)
    %{
    A function used to generate figures in the paper.
    Replace the fig with any figure index (as str) you see in the paper.
    Please do not include space in the str. 
    for example, to obtain figure 1, fig = 'figure1'
    although... we do not have figure 1...
    %}
        
    if strcmp(fig, 'figure2.1')
        
        open('figures/Figure2E_fitSOCbbpower.fig');
        subplot(8,1,1);
        x = get(gca, 'UserData');
        close all;
        
        fontsize = 7.5;
        cur_color = ones(1,3) * .6;
        gra_color = ones(1,3) * .8;
        cur_stims = 78:-1:74;
        gra_stims = 73:-1:69;
        figure;
        fig_width = 6;
        pos = [10, 5, fig_width, .5*fig_width];
        set( gcf, 'unit', 'centimeters', 'position', pos, 'color', 'w');
        bar(1:5, x.mn(cur_stims), 'Facecolor', cur_color, 'EdgeColor', cur_color); hold on;
        e1 = errorbar(1:5, x.mn(cur_stims), x.err(cur_stims), x.err(cur_stims));
        bar(7:11, x.mn(gra_stims), 'Facecolor', gra_color, 'EdgeColor', gra_color); hold on;
        e2 = errorbar(7:11, x.mn(gra_stims), x.err(gra_stims), x.err(cur_stims));
        set(e1,'LineStyle', 'none','Color', .2*[1 1 1]);
        set(e2,'LineStyle', 'none','Color', .2*[1 1 1]);
        set( gca, 'XTickLabel', '');
        set (gca, 'FontSize', fontsize);
        box off 
        
    elseif strcmp( fig, 'figureS1')
            
        stim = dataloader( stdnormRootPath, 'stimuli', 'All', 4, 1 );
        figure;
        set( gcf, 'color', 'w');
        for ii = 1:size(stim, 4)
            subplot( 5, 10, ii)
            imshow( stim( :, :, 1, ii), []);
        end
        
    elseif strcmp( fig, 'figure7')

        % get the plot color
        v3      = [ .1, .1, .1]; 
        v2      = [ .5, .5, .5]; 
        v1      = [ .9, .9, .9]; 
        models = { 'CE', 'SOC', 'OTS', 'NOA', 'Data'};
        
        % get stimuli
        T = readtable( fullfile( stdnormRootPath, 'Tables/hetero_tables.csv'));
        snakes_mean   = NaN( 3, length(models));
        gratings_mean = NaN( 3, length(models));
        snakes_std    = NaN( 3, length(models));
        gratings_std  = NaN( 3, length(models));
        
        for i = 1:length(models)
           start_idx = (i - 1) * 4 + 1;
           end_idx   = 4 * i; 
           vars_nm = T.Properties.VariableNames;
          
           for j = 2:length( vars_nm)
               if mod( j , 2)
                  gratings_mean( floor(j/2), i) = mean(T{ start_idx:end_idx, vars_nm{j}});
                  gratings_std( floor(j/2), i)  = std(T{ start_idx:end_idx, vars_nm{j}});
               else
                  snakes_mean( floor(j/2), i) = mean(T{ start_idx:end_idx, vars_nm{j}});
                  snakes_std( floor(j/2), i)  = std(T{ start_idx:end_idx, vars_nm{j}});
               end
           end    
        end
        contrast = (snakes_mean - gratings_mean) ./ (snakes_mean + gratings_mean) /2;
        x = 1:length(models);
        b = bar( x, contrast');
        b(1).FaceColor  = v1; 
        b(2).FaceColor  = v2; 
        b(3).FaceColor  = v3;
%         hold on
%         er = errorbar(x,data,errlow,errhigh);    
%         er.Color = [0 0 0];                            
%         er.LineStyle = 'none';  
        xticklabels( models)
        legend( 'V1', 'V2', 'V3')
        

    elseif strcmp( fig, 'figure9')

        % get the plot color
        curvy = [ .4, .4, .4] + .1; 
        grating = [ .6, .6, .6] + .1; 
        ep = 5;
        s  = 4;
        w = 100;

        % get stimuli
        stim_ind = [ 8, 3, 35, 47];
        colors   = { grating, curvy, grating, curvy};
        stim = dataloader( stdnormRootPath, 'stimuli', 'all', 1, 1);
        E_ori = dataloader( stdnormRootPath, 'E_ori', 'all', 1, 1);
        stim = squeeze(stim( :, :, ep, stim_ind));
        E_ori = s * squeeze(E_ori( :, ep, stim_ind));
        
        for i = 1:length(stim_ind)
            % visualize the raw stimuli
            x = E_ori( : , i);
            d = x ./ (1 + w * var(x) );
            subplot( 4, 3, (i-1)*3 + 1)
            imshow( stim( :, :, i), [-.1, .1]);
            axis off 
            % visualize E_ori^2 
            subplot( 4, 3, (i-1)*3 + 2)
            bar( x, 'FaceColor', colors{i},...
                            'EdgeColor', colors{i});
            set(gca,'xtick',[])
            ylim( [ 0, .3])
            sum_txt = sprintf( 'sum=%.2f', sum(x));
            text( .1, .28, sum_txt)
            var_txt = sprintf( 'var=%.4f', var(x));
            text( .1, .25, var_txt)
            box off 
            % visualize d 
            subplot( 4, 3, (i-1)*3 + 3)
            bar( d, 'FaceColor', colors{i},...
                        'EdgeColor', colors{i});
            set(gca,'xtick',[])
            ylim( [ 0, .3])
            sum_txt = sprintf( 'sum=%.2f', sum(d));
            text( .1, .28, sum_txt)
            box off 
        end
        
    else
        
        % Tune the hyperparameters
        doModel          = true;
        optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
        error_bar        = true;
        data_folder      = 'Cross';  % save in which folder. value space: 'noCross', .....
        target           = 'target';
        switch fig
            
            case {'figure2'}
                doModel  = false;
            case {
                    'figure8'  ,... 
                    'figureS3a', 'figureS3b', 'figureS3c',...
                    'figureS4a', 'figureS4b', 'figureS4c', 'figureS4d',...
                    'figureS5a', 'figureS5b', 'figureS5c', 'figureS5d',...
                    'figureS6a', 'figureS6b', 'figureS6c', 'figureS6d',...
                }
                target   = 'all';
        end
        
        % Generate save address and  choose data
        figure_address = fullfile(stdnormRootPath, 'figures', data_folder, target, optimizer);
        if ~exist(figure_address, 'dir'), mkdir(figure_address); end
        
        % Choose data as if we are doing parallel computing
        T = chooseData( fig, optimizer, 40 );
        model_ind = sort(unique(T.modelNum))';
        
        %% Load data 

        % Init the data storages
        numstimuli            = 50;
        all_datasets          = unique(T.dataset);
        nummodels             = length( unique(T.modelNum));
        numrois               = length( unique(T.roiNum));
        numdatasets           = length( unique(T.dataset));
        pred_summary_all      = NaN( numstimuli,nummodels,numdatasets, numrois);
        targ_pred_summary_all = NaN( numstimuli,nummodels,numdatasets, numrois);
        data_summary_all      = NaN( numstimuli,1,numdatasets, numrois);
        err_summary_all       = NaN( numstimuli,1,numdatasets, numrois);
        num_stimuli           = NaN( numdatasets,1);
        
        % Loop through datasets and load model predictions and data
        for data_idx = 1:numdatasets
            
            % select data set 
            dataset = all_datasets(data_idx);
            
            for roi = 1:numrois
                for idx = 1:nummodels
                    
                    % select model 
                    model_idx = T.modelNum( idx);
                    
                    % load BOLD target
                    BOLD_data = dataloader( stdnormRootPath, 'BOLD_target', 'all', dataset, roi );
                    len_stim = length( BOLD_data);
                    num_stimuli( data_idx) = len_stim;
                    data_summary_all(1:len_stim, 1, data_idx, roi) = BOLD_data';
                    
                    % load errorbar
                    if error_bar
                        BOLD_data_error = dataloader( stdnormRootPath, 'BOLD_target_error', 'all', dataset, roi );
                        err_summary_all(1:len_stim, 1, data_idx, roi) = BOLD_data_error';
                    end

                    % load BOLD prediction for all stimuli
                    if doModel
                        target_pred = dataloader( stdnormRootPath, 'BOLD_pred', 'all', dataset, roi, data_folder, model_idx, optimizer);
                        pred_summary_all(1:len_stim, idx, data_idx, roi) = target_pred;
                    end

                    % load BOLD prediction for the target data (this is a bit tricky)
                    % Because plot_BOLD is designed to generate figures using
                    % the whole dataset, I load the target data set in the form of 
                    % full dataset, with all nan but all valued for targets.
                    target_BOLD_pred = dataloader( stdnormRootPath, 'BOLD_pred', 'target', dataset, roi, data_folder, model_idx, optimizer);
                    if doModel
                        switch dataset
                            case 1
                                target_ind = [ 1:10, 35:38, 47:50];
                            case 2
                                target_ind = [ 1:10, 33:36, 45:48];
                            case {3, 4}
                                target_ind = [ 9:12,    26, 28:39];
                        end
                        targ_pred_summary_all( target_ind, idx, data_idx, roi) = target_BOLD_pred';
                    end
                end
            end
        end
        
        %% Make figures
        
        if strcmp( target, 'target')
            
            %%%%%%%%%%%%%%% Fig. for target data set  %%%%%%%%%%%%%%%%

            % Intialize a figure
            fig_width = 20;
            fig_height = 3.5 * numdatasets;
            pos = [10, 5, 2*fig_width, 2*fig_height];
            set( gcf, 'unit', 'centimeters', 'position', pos, 'color', 'w');
            subplot( numdatasets, numrois+1, numdatasets+1)
            
            % Loop through datasets and make plots
            for data_idx = 1:numdatasets
                
                dataset = all_datasets(data_idx);
                
                % for each each ori area
                for roi = 1:numrois
                    % get the total length of the data
                    len_stim  = num_stimuli( data_idx);
                    % get the data for plots
                    BOLD_data = data_summary_all( 1:len_stim, 1, data_idx, roi)';
                    % get the error bar for plots
                    BOLD_err = err_summary_all( 1:len_stim, 1, data_idx, roi)';
                    % get the model prediction
                    target_preds = targ_pred_summary_all( 1:len_stim, :, data_idx, roi)';
                    
                    % subplot dataset, roi, idx
                    idx = (data_idx-1)*(numrois+1) + roi;
                    subplot( numdatasets, numrois+1, idx)
                    plot_BOLD( target_preds, BOLD_data, BOLD_err, dataset, model_ind, targetz);

                    % display title
                    show_title = sprintf( 'V%d', roi);
                    title( show_title )
                    
                    % add legend to specify the model's predictions
                    if doModel
                        if idx ==numrois
                            subplot( numdatasets, numrois+1, idx+1)
                            plot_legend( target_preds, model_ind)
                        end
                    end
                end
            end
            
        else
            %%%%%%%%%%%%%%% Fig. for whole data set  %%%%%%%%%%%%%%%%
            
            % init a figure
            fig_width  = 17;
            fig_height = 17;
            pos = [10, 5, 2*fig_width, 2*fig_height];
            set( gcf, 'unit', 'centimeters', 'position', pos, 'color', 'w');
            
            
            % Loop through datasets and make plots
            for data_idx = 1:numdatasets
                
                dataset = all_datasets(data_idx);
                
                % for each each ori area
                for roi = 1:numrois

                    % get the total length of the data
                    len_stim  = num_stimuli( data_idx);
                    % get the data for plots
                    BOLD_data = data_summary_all( 1:len_stim, 1, data_idx, roi)';
                    % get the error bar for plots
                    BOLD_err  = err_summary_all( 1:len_stim, 1, data_idx, roi)';
                    % get the model prediction
                    BOLD_preds = pred_summary_all( 1:len_stim, :, data_idx, roi)';
                    
                    % subplot dataset, roi, idx
                    subplot( numrois+1, 1, roi)
                    
                    % if we add model prediction
                    plot_BOLD( BOLD_preds, BOLD_data, BOLD_err, dataset, model_ind, target)
                    
                    % display title
                    show_title = sprintf( 'V%d', roi);
                    title( show_title )
                end
                
                % add legend to specify the model's predictions
                if doModel
                    subplot( numrois+1, 1, roi+1)
                    plot_legend( BOLD_preds, model_ind)
                end
            end
        end
    end
end

