%% clear the memory

clear all; close all; clc
%% hyperparameter: each time, we only need to edit this section !!

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'All';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'noCross';  % save in which folder. value space: 'noCross', .....
cross_valiad   = 'one';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.

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
T      = chooseData( 'orientation', optimizer, fittime );

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
    figure;set(gcf, 'Position', [200 100 1100 960])
    sgtitle( 'Fitted Result: Target stimuli' )
end

for dataset = 1:numdatasets
    
    if strcmp( target, 'target' )==0
        figure;set(gcf, 'Position', [200 100 1100 960])
    end
    
    
    for roi = 1:numrois
        for model_idx = 1:nummodels
            
            % load BOLD target
            BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi );
            len_stim = length( BOLD_target );
            
            % load BOLD prediction
            BOLD_pred = dataloader( prevPath, 'BOLD_pred', target, dataset, roi, data_folder, model_idx, optimizer);
            pred_summary_all(1:len_stim, model_idx, dataset, roi) = BOLD_pred';
            
        end
        
        if strcmp( target, 'target' )
            
            % subplot dataset, roi, idx
            idx = (dataset-1)*numrois + roi;
            subplot( numdatasets, numrois, idx)
            legend = { 'BOLD', 'contrast', 'normStd', 'normVar'};
            plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_target, dataset, roi, legend, target )
            show_title = sprintf( 'Dataset%d-V%d', dataset, roi );
            title( show_title )
            
        else
            % subplot nroi, 1, roi
            subplot( numrois, 1, roi )
            legend = { 'BOLD', 'contrast', 'normStd', 'normVar'};
            plot_BOLD( pred_summary_all(1:len_stim, :, dataset, roi), BOLD_target, dataset, roi, legend, target )
            show_title = sprintf( 'Dataset%d-V%d', dataset, roi );
            title( show_title )
        end
        
    end
    
    if strcmp( target, 'target' ) ==0
        % define filename and save the file
        filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d', dataset) );
        savefig(filename)
        %print
        filename = fullfile( pdf_address, sprintf(  '/BOLD_fit-dataset%d', dataset) );
        print(filename,'-dpng')
    end
    
end

if strcmp( target, 'target' )
    % define filename and save the file
    filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d', dataset) );
    savefig(filename)
    %print
    filename = fullfile( pdf_address, sprintf(  '/BOLD_fit-dataset%d', dataset) );
    print(filename,'-dpng')
end

%% plot loss histogram

for dataset = 1:numdatasets
    
    % initate a figure for each dataset
    figure;set(gcf,'PaperType','a3')
    set(gca,'xtick',[])
    
    for roi = 1:numrois
        for model_idx = 1:nummodels
            
            % load loss_log
            loss_log = dataloader( prevPath, 'Loss_log', target, dataset, roi, data_folder , model_idx, optimizer);
            min_num = sum((loss_log - min(loss_log))<10e-5);
            
            % subplot dataset, roi, idx
            idx = (roi-1)*nummodels + model_idx;
            subplot( numrois, nummodels, idx)
            histogram( loss_log, 20 )
            show_title = sprintf( 'Dataset%d-V%d-M%d-min-%d', dataset, roi, model_idx, min_num );
            title( show_title )
            
        end
        
        
    end
    
    % define filename and save the file
    filename = fullfile( figure_address, sprintf(  '/BOLD_fit-dataset%d', dataset) );
    savefig(filename)
    %print
    filename = fullfile( pdf_address, sprintf(  '/BOLD_fit-dataset%d', dataset) );
    print(filename,'-dpng')
    
end
