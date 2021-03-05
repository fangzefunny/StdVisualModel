
function [] = create_plots(fig)

% import packages
addpath( genpath( fullfile( stdnormRootPath, 'functions' )))
addpath( genpath( fullfile( stdnormRootPath, 'models' )))
addpath( genpath( fullfile( stdnormRootPath, 'plot' )))


if strcmp(fig, 'figure1.1')
    
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
        
     stim = dataloader( stdnormRootPath, 'stimuli', 'All', 1, 1 );
     figure;
     set( gcf, 'color', 'w');
     for ii = 1:size(stim, 4)
         subplot( 5, 10, ii)
         imshow( stim( :, :, 1, ii), []);
     end

else
    
    
    %%%%%%%%%%%%%%%%%
    %  Hyperparams  %
    %%%%%%%%%%%%%%%%%
    
    % Set up hyperparameters
    doModel          = true;
    optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
    error_bar        = true;
    data_folder      = 'Cross';  % save in which folder. value space: 'noCross', .....
    target           = 'target';
    switch fig
        
        case {'figure1'}
            doModel  = false;
        case {'figure6', 'figure7', 'figureS3', ...
                'figureS4', 'figureS5'}
            target   = 'all';
    end
    
    % Generate save address and  choose data
    figure_address = fullfile(stdnormRootPath, 'figures', data_folder, target, optimizer);
    if ~exist(figure_address, 'dir'), mkdir(figure_address); end
    
    % Choose data as if we are doing parallel computing
    T = chooseData( fig, optimizer, 40 );
    model_ind = sort(unique(T.modelNum))';
    
    
    %%%%%%%%%%%%%%%
    %  Load Data  %
    %%%%%%%%%%%%%%%
    
    % Init the data storages
    all_datasets = unique(T.dataset);
    nummodels   = length(unique(T.modelNum));
    numrois     = length(unique(T.roiNum));
    numdatasets = length(unique(T.dataset));
    numstimuli = 50;
    pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
    data_summary_all = NaN(numstimuli,1,numdatasets, numrois);
    err_summary_all  = NaN(numstimuli,1,numdatasets, numrois);
    num_stimuli      = NaN(numdatasets,1);
    
    % Loop through datasets and load model predictions and data
    for data_idx = 1:numdatasets
        
        dataset = all_datasets(data_idx);
        
        for roi = 1:numrois
            for idx = 1:nummodels
                
                model_idx = T.modelNum( idx);
                
                % load BOLD target
                BOLD_data = dataloader( stdnormRootPath, 'BOLD_target', target, dataset, roi );
                len_stim = length( BOLD_data);
                num_stimuli( data_idx) = len_stim;
                data_summary_all(1:len_stim, 1, data_idx, roi) = BOLD_data';
                
                % load errorbar
                BOLD_data_error = dataloader( stdnormRootPath, 'BOLD_target_error', target, dataset, roi );
                err_summary_all(1:len_stim, 1, data_idx, roi) = BOLD_data_error';
                
                % load BOLD prediction
                BOLD_pred = dataloader( stdnormRootPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, optimizer);
                if ~isempty(BOLD_pred)
                    pred_summary_all(1:len_stim, idx, data_idx, roi) = BOLD_pred';
                else
                    pred_summary_all(1:len_stim, idx, data_idx, roi) = NaN;
                end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%
    %  Make plots  %
    %%%%%%%%%%%%%%%%
    
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
                BOLD_data = data_summary_all(1:len_stim, 1, data_idx, roi)';
                % get the error bar for plots
                BOLD_data_error = err_summary_all(1:len_stim, 1, data_idx, roi)';
                % get the model prediction
                BOLD_pred = pred_summary_all(1:len_stim, :, data_idx, roi);
                
                % subplot dataset, roi, idx
                idx = (data_idx-1)*(numrois+1) + roi;
                subplot( numdatasets, numrois+1, idx)
                if doModel
                    if error_bar
                        plot_BOLD( BOLD_pred, BOLD_data, dataset, roi, target, model_ind, BOLD_data_error );
                    else
                        plot_BOLD( BOLD_pred, BOLD_data, dataset, roi, target, model_ind );
                    end
                else
                    nan_prediction = NaN( size( pred_summary_all(1:len_stim, :, data_idx, roi)));
                    plot_BOLD( nan_prediction, BOLD_data, dataset, roi, target, model_ind, BOLD_data_error);
                end
                
                % display title
                show_title = sprintf( 'V%d', roi);
                title( show_title )
                
                % add legend to specify the model's predictions
                if idx ==numrois
                    subplot( numdatasets, numrois+1, idx+1)
                    plot_legend( pred_summary_all(1:len_stim, :, data_idx, roi), model_ind)
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
                % get the data for plots
                BOLD_data = data_summary_all(1:len_stim, 1, data_idx, roi)';
                len_stim  = num_stimuli( data_idx);
                % subplot dataset, roi, idx
                subplot( numrois+1, 1, roi)
                
                % if we add model prediction
                if doModel
                    if error_bar
                        plot_BOLD( pred_summary_all(1:len_stim, :, data_idx, roi), BOLD_data, dataset, roi, target, model_ind, BOLD_data_error )
                    else
                        plot_BOLD( pred_summary_all(1:len_stim, :, data_idx, roi), BOLD_data, dataset, roi, target, model_ind )
                    end
                else
                    nan_prediction = NaN( size( pred_summary_all(1:len_stim, :, data_idx, roi)));
                    plot_BOLD( nan_prediction, BOLD_data, dataset, roi, target, model_ind, BOLD_data_error)
                end
                
                % display title
                show_title = sprintf( 'V%d', roi);
                title( show_title )
            end
            
            % add legend to specify the model's predictions
            if doModel
                subplot( numrois+1, 1, roi+1)
                plot_legend( pred_summary_all(1:len_stim, :, data_idx, roi), model_ind)
            end
        end
    end
    
end
end

