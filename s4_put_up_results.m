%% clear

clear all; close all; clc;
%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot' )))

%% choose data and hyperparameter

T = chooseData( 'orientation' );

nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
numparams = 3;

%% start loop

load_option = 'no_cross'; % 'old', 'new', 'no_cross'
target = 'target'; % 'all', 'target'

% storages
para_summary = NaN( numdatasets, numrois );
para_std = NaN( numstimuli, numparams, nummodels, numdatasets, numrois );
pred_summary_all = NaN(numstimuli,nummodels,numdatasets, numrois);
Rsqu_summary_all = NaN(nummodels,numdatasets, numrois);

if strcmp( target, 'target' ) 
        figure;set(gcf, 'Position', [200 100 1100 960])
        sgtitle( 'Fitted Result: Target stimuli' )
end

for dataset = 1:numdatasets
    
    if strcmp( target, 'target' )==0 
        figure;set(gcf, 'Position', [200 100 1100 960])
        %title = sprintf( 'Fitted Result: Dataset %d', dataset);
        %sgtitle( title )
    end
        
    
    for roi = 1:numrois
        for model_idx = 1:nummodels
            
            % load BOLD target
            BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi, load_option );
            len_stim = length( BOLD_target );
            
            % load parameters
            %params = dataloader( prevPath, 'param', dataset, roi, 'new', model_idx );
            %para_summary_all( 1:size(params,1) , : , model_idx , dataset, roi) = params;
            
            % load R square
            %Rsquare = dataloader( prevPath, 'Rsqaure', dataset, roi, 'new', model_idx );
            %Rsqu_summary_all(model_idx, dataset, roi) = Rsquare;
            
            % load BOLD prediction
            BOLD_pred = dataloader( prevPath, 'BOLD_pred', target, dataset, roi, load_option , model_idx );
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
        save_figure = sprintf( 'figures/%s', load_option);
        if ~exist(save_figure, 'dir'), mkdir(save_figure); end
        filename = sprintf( 'figures/%s/dataset%d-%s', load_option, dataset, target);
        savefig(filename)
        %print
        print_figure = sprintf( 'pdf/%s', load_option);
        if ~exist(print_figure, 'dir'), mkdir(print_figure); end
         filename = sprintf( 'pdf/%s/dataset%d-%s', load_option, dataset, target);
        print(filename,'-dpng')
    end
    
end

if strcmp( target, 'target' )
        % define filename and save the file
        save_figure = sprintf( 'figures/%s', load_option);
        if ~exist(save_figure, 'dir'), mkdir(save_figure); end
        filename = sprintf( 'figures/%s/alldataset-%s', load_option, target);
        savefig(filename)
        %print
        print_figure = sprintf( 'pdf/%s', load_option);
        if ~exist(print_figure, 'dir'), mkdir(print_figure); end
         filename = sprintf( 'pdf/%s/alldataset%d-%s', load_option, target);
        print(filename,'-dpng')
    end
