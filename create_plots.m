
function [] = create_plots( )
fig= 'figure2'
doCross = true;
target = 'target';
doModel = true; 

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
fittime          = 40;         % how manoy initialization. value space: Integer
error_bar        = true;
choose_model     = fig;      % choose some preset data

switch doCross
    case false
        cross_valid  = 'one';            % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'noCross';       % save in which folder. value space: 'noCross', .....
        print_loss   = true;
        
    case true
        cross_valid  = 'cross_valid';   % choose what kind of cross , value space: 'one', 'cross_valid'. 'one' is no cross validation.
        data_folder  = 'Cross';         % save in which folder. value space: 'noCross', .....
        print_loss   = false;           % we don't save all the loss plots when we cross validate
end


%% generate save address and  choose data

% save address
figure_address = fullfile(stdnormRootPath, 'figures', data_folder, target,  optimizer);
if ~exist(figure_address, 'dir'), mkdir(figure_address); end

% choose data as if we are doing parallel computing
T      = chooseData( choose_model, optimizer, fittime );

%% Load data into a matrix 

% Obtain some features of the storages
nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
numparams = 3;

% Initialize variables 
pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
Rsqu_summary_all = NaN(nummodels,numdatasets, numrois);
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

%% Make plots 

% Intialize a figure
if strcmp( target, 'target' )
    % figure size: figure is design to fit in 2 col (about 16cm wdith)
    fig_width = 20;
    fig_height = 3.5 * numdatasets;
    pos = [10, 5, 2*fig_width, 2*fig_height];
    set( gcf, 'unit', 'centimeters', 'position', pos);
    subplot( numdatasets, numrois+1, numdatasets+1)
end

% Loop through datasets and make plots
for dataset = 1:numdatasets
    
    if strcmp( target, 'target' )==0
        % figure size: figure is design to fit in 2 col (about 16cm wdith)
        fig_width = 16;
        fig_height = 10;
        pos = [10, 5, 10+fig_width, 10+fig_height];
        set( gcf, 'unit', 'centimeters', 'position', pos);
        set( gca, 'FontSize', 9) 
        figure;
    end
    
    for roi = 1:numrois
        for idx = 1:nummodels
            model_idx = T.modelNum( idx);      
        end

        BOLD_data = data_summary_all(1:len_stim, 1, dataset, roi)';
          
        if strcmp( target, 'target' )
            
            % subplot dataset, roi, idx
            idx = (dataset-1)*(numrois+1) + roi;
            subplot( numdatasets, numrois+1, idx)
            if doModel
                if error_bar
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target, BOLD_data_error );
                else
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target );
                end
            else
                nan_prediction = NaN( size( pred_summary_all(1:len_stim, :, dataset, roi)));
                plot_BOLD( nan_prediction, BOLD_data, dataset, roi, target)
            end
            
            show_title = sprintf( 'Dataset%d-V%d', dataset, roi );
            title( show_title )
            if idx ==numrois
                subplot( numdatasets, numrois+1, idx+1)
                plot_legend( pred_summary_all(1:len_stim, :, dataset, roi))
            end
            
        else
            % subplot nroi, 1, roi
            subplot( numrois, 1, roi )
            if doModel
                if error_bar
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target, BOLD_data_error )
                else
                    plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_data, dataset, roi, target )
                end
            else
                nan_prediction = NaN( size( pred_summary_all(1:len_stim, :, dataset, roi)));
                plot_BOLD( nan_prediction, BOLD_data, dataset, roi)
            end
            
            show_title = sprintf( 'Dataset%d-V%d', dataset, roi );
            title( show_title )
        end
        
    end
end

end 