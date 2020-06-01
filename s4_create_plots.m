%% clear the memory

clear all; close all; clc

%% hyperparameter: each time, we only need to edit this section !!

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'all';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'Cross';  % save in which folder. value space: 'noCross', .....
cross_valid   = 'cross_valid';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.
choose_data = 'all';          % choose some preset data
error_bar = false;
print_loss = false;

%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot' )))

%% generate save address and  choose data

% save address
figure_address = fullfile(curPath, 'figures', data_folder, target,  optimizer);
if ~exist(figure_address, 'dir'), mkdir(figure_address); end
pdf_address = fullfile(curPath, 'pdf', data_folder, target, optimizer);
if ~exist(pdf_address, 'dir'), mkdir(pdf_address); end


% choose data as if we are doing parallel computing
T      = chooseData( choose_data, optimizer, fittime );

%% plot prediction

% obtain some features of the storages
nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
numparams = 3;

% storages
pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
Rsqu_summary_all = NaN(nummodels,numdatasets, numrois);

if strcmp( target, 'target' )
    figure;set(gcf, 'Position', [200 100 1400 960])
    sgtitle( 'Fitted Result: Target stimuli' )
    subplot( numdatasets, numrois+1, numdatasets+1)
    %legend( { 'BOLD', 'contrast', 'normStd', 'normVar'});
    
end

for dataset = 1:numdatasets
    
    if strcmp( target, 'target' )==0
        figure;set(gcf, 'Position', [200 100 1100 960])
    end
    
    
    for roi = 1:numrois
        for idx = 1:nummodels
            
            model_idx = T.modelNum( idx);
            
            % load BOLD target
            BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi );
            len_stim = length( BOLD_target );
            
            % load errorbar 
            if error_bar
                 BOLD_target_error = dataloader( prevPath, 'BOLD_target_error', target, dataset, roi );
            end
            
            % load BOLD prediction
            BOLD_pred = dataloader( prevPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, optimizer);
            pred_summary_all(1:len_stim, idx, dataset, roi) = BOLD_pred';
            
        end
        
        if strcmp( target, 'target' )
            
            % subplot dataset, roi, idx
            idx = (dataset-1)*(numrois+1) + roi;
            subplot( numdatasets, numrois+1, idx)
            if error_bar 
                plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_target, dataset, roi, target, BOLD_target_error );
            else
                plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_target, dataset, roi, target );
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
            if error_bar
                plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_target, dataset, roi, target, BOLD_target_error )
            else
                plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_target, dataset, roi, target )
            end
            show_title = sprintf( 'Dataset%d-V%d', dataset, roi );
            title( show_title )
        end
        
    end
    
    if strcmp( target, 'target' ) ==0
        % define filename and save the file
        if error_bar
            filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d-%s-error', dataset, target) );
            savefig(filename)
            %print
            filename = fullfile( pdf_address, sprintf( '/BOLD_fit-dataset%d-%s-error', dataset, target) );
            print(filename,'-dpng')
        else
            filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d-%s', dataset, target) );
            savefig(filename)
            %print
            filename = fullfile( pdf_address, sprintf( '/BOLD_fit-dataset%d-%s', dataset, target) );
            print(filename,'-dpng')
        end
    end
    
end

if strcmp( target, 'target' )
    if error_bar
        % define filename and save the file
        filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d-%s-error', dataset, target) );
        savefig(filename)
        %print
        filename = fullfile( pdf_address, sprintf(  '/BOLD_fit-dataset%d-%s-error', dataset, target) );
        print(filename,'-dpng')
    else
        % define filename and save the file
        filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d-%s', dataset, target) );
        savefig(filename)
        %print
        filename = fullfile( pdf_address, sprintf(  '/BOLD_fit-dataset%d-%s', dataset, target) );
        print(filename,'-dpng')
    end
end

%% plot loss histogram

if print_loss
    
    for dataset = 1:numdatasets
        
        % initate a figure for each dataset
        figure;set(gcf,'PaperType','a3')
        set(gca,'xtick',[])
        
        for roi = 1:numrois
            for ii = 1:nummodels
                
                model_idx = T.modelNum( ii);
                
                % load loss_log
                loss_log = dataloader( prevPath, 'Loss_log', target, dataset, roi, data_folder , model_idx, optimizer);
                min_num = sum((loss_log - min(loss_log))<.01);
                
                % subplot dataset, roi, idx
                idx = (roi-1)*nummodels + ii;
                subplot( numrois, nummodels, idx)
                histogram( loss_log, 'BinWidth', 0.01 )
                xlim( [0,.5]) 
                show_title = sprintf( 'Dataset%d-V%d-M%d\n-min-%d', dataset, roi, model_idx, min_num );
                title( show_title )
                
            end
            
            
        end
        
        % define filename and save the file
        filename = fullfile( figure_address, sprintf(  '/loss_log-dataset%d-%s', dataset, target) );
        savefig(filename)
        %print
        filename = fullfile( pdf_address, sprintf(  '/loss_log-dataset%d-%s', dataset, target) );
        print(filename,'-dpng')
        
    end
end
