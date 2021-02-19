
function [] = create_plots(fig)

% What should I do to add the path
addpath( genpath( fullfile( stdnormRootPath, 'functions' )))
addpath( genpath( fullfile( stdnormRootPath, 'models' )))
addpath( genpath( fullfile( stdnormRootPath, 'plot' )))

%%%%%%%%%%%%%%%%%
%  Hyperparams  %
%%%%%%%%%%%%%%%%%

% Set up hyperparameters
doModel          = true;
optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
error_bar        = false;
data_folder      = 'Cross';  % save in which folder. value space: 'noCross', .....
smallfig         = true;

switch fig
    case {'figure1'}
        target   = 'target';
        error_bar = true;
        doModel  = false;
        
    case {'figure2', 'figure3', 'figure5'}
        target   = 'target';
        
    case {'figure6', 'figure6.1', 'figure6.2', 'figure6.3', 'figure7'}
        target   = 'all';
        smallfig = false;
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
nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
data_summary_all = NaN(numstimuli,1,numdatasets, numrois);

% Loop through datasets and load model predictions and data
for dataset = 1:numdatasets
    
    for roi = 1:numrois
        for idx = 1:nummodels
            
            model_idx = T.modelNum( idx);
            
            % load BOLD target
            BOLD_data = dataloader( stdnormRootPath, 'BOLD_target', target, dataset, roi );
            len_stim = length( BOLD_data );
            data_summary_all(1:len_stim, 1, dataset, roi) = BOLD_data';
            
            % load errorbar
            BOLD_data_error = dataloader( stdnormRootPath, 'BOLD_target_error', target, dataset, roi );
            
            % load BOLD prediction
            BOLD_pred = dataloader( stdnormRootPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, optimizer);
            if ~isempty(BOLD_pred)
                pred_summary_all(1:len_stim, idx, dataset, roi) = BOLD_pred';
            else
                pred_summary_all(1:len_stim, idx, dataset, roi) = NaN;
            end
        end
    end
end

%%%%%%%%%%%%%%%%
%  Make plots  %
%%%%%%%%%%%%%%%%

if smallfig
    
    % Make 3 mini figures in one row 3 columns
    
    % Intialize a figure
    fig_width = 20;
    fig_height = 3.5 * numdatasets;
    pos = [10, 5, 2*fig_width, 2*fig_height];
    set( gcf, 'unit', 'centimeters', 'position', pos);
    subplot( numdatasets, numrois+1, numdatasets+1)
    
    % Loop through datasets and make plots
    for dataset = 1:numdatasets
        for roi = 1:numrois
            
            BOLD_data = data_summary_all(1:len_stim, 1, dataset, roi)';
            
            % subplot dataset, roi, idx
            idx = (dataset-1)*(numrois+1) + roi;
            subplot( numdatasets, numrois+1, idx)
            if doModel
                if error_bar
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target, model_ind, BOLD_data_error );
                else
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target, model_ind );
                end
            else
                nan_prediction = NaN( size( pred_summary_all(1:len_stim, :, dataset, roi)));
                plot_BOLD( nan_prediction, BOLD_data, dataset, roi, target, model_ind, BOLD_data_error);
            end
            
            show_title = sprintf( 'V%d', roi);
            title( show_title )
            if idx ==numrois
                subplot( numdatasets, numrois+1, idx+1)
                plot_legend( pred_summary_all(1:len_stim, :, dataset, roi), model_ind)
            end
        end
    end
    
else
    % Make 3 mini figures in 3 rows
    
    % init a figure
    fig_width  = 17;
    fig_height = 17;
    pos = [10, 5, 2*fig_width, 2*fig_height];
    set( gcf, 'unit', 'centimeters', 'position', pos);
    
    
    % Loop through datasets and make plots
    for dataset = 1:numdatasets
        for roi = 1:numrois
            
            BOLD_data = data_summary_all(1:len_stim, 1, dataset, roi)';
            
            % subplot dataset, roi, idx
            subplot( numrois+1, 1, roi)
            if doModel
                if error_bar
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target, model_ind, BOLD_data_error )
                else
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target, model_ind )
                end
            else
                nan_prediction = NaN( size( pred_summary_all(1:len_stim, :, dataset, roi)));
                plot_BOLD( nan_prediction, BOLD_data, dataset, roi, target, model_ind, BOLD_data_error)
            end
            
            show_title = sprintf( 'V%d', roi);
            title( show_title )
        end
        if doModel
            subplot( numrois+1, 1, roi+1)
            plot_legend( pred_summary_all(1:len_stim, :, dataset, roi), model_ind)
        end
    end
end

end

