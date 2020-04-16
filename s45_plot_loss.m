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


for dataset = 1:numdatasets
    
    % initate a figure for each dataset
   figure;set(gcf,'PaperType','a3')
   set(gca,'xtick',[])

    for roi = 1:numrois
        for model_idx = 1:nummodels
            
            % load loss_log
            loss_log = dataloader( prevPath, 'Loss_log', target, dataset, roi, load_option , model_idx );
            
            % subplot dataset, roi, idx
            idx = (roi-1)*nummodels + model_idx;
            subplot( numrois, nummodels, idx)
            histogram( loss_log, 20 )
            show_title = sprintf( 'Dataset%d-V%d-M%d', dataset, roi, model_idx );
            title( show_title )
            
        end
        

    end
    
    % define filename and save the file
        save_figure = sprintf( 'figures/%s', load_option);
        if ~exist(save_figure, 'dir'), mkdir(save_figure); end
        filename = sprintf( 'figures/%s/loss_log-dataset%d-%s', load_option, dataset, target);
        savefig(filename)
        
        %print 
        print_figure = sprintf( 'pdf/%s', load_option);
        if ~exist(print_figure, 'dir'), mkdir(print_figure); end
         filename = sprintf( 'pdf/%s/loss_log-dataset%d-%s', load_option, dataset, target);
        print(filename,'-dpng')

    
end

