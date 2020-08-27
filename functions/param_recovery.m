clear all; close all; clc 

%% set path

[curPath, prevPath] = stdnormRootPath();
save_address = fullfile(prevPath, 'Data', 'no_cross', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot_tools' )))

%%  choose data and hyperparameter

T = chooseData( 'orientation' );
len = size( T, 1 );
target = 'all';
load_option = 'no_cross';
nfake = 9;
nummodels   = length(unique(T.modelNum));
numrois     = length(unique(T.roiNum));
numdatasets = length(unique(T.dataset));
numstimuli = 50;
numparams = 3;

%% start loop

performance = nan( 4,3,3,10);

for job = 1: len
    
    % obtain data index
    dataset = T.dataset( job );
    
    % obtain  roi index
    roi = T.roiNum( job );
    
    % obain model index
    model_idx = T.modelNum(job);
    
    % load model
    model = T.modelLoader{model_idx};
    
    % display information to keep track
    display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
    disp( display )
    
    % load model prediction 
    BOLD_pred = dataloader( prevPath, 'BOLD_pred', target, dataset, roi, load_option , model_idx );
    
    % load taget BOLD signal
    BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi, load_option );
    
    % calculate the performance
    performance(dataset, roi, model_idx, 1) = model.mse(  BOLD_pred, BOLD_target );
    
   % predict the synthetic data 
    for fake_idx = 1: nfake
        
        % load the fake data
        BOLD_target_fake = fakedataloader( prevPath, target, dataset, roi, model_idx, fake_idx);
        
        % calculate the performance
        performance( dataset, roi, model_idx, fake_idx +1 ) = model.mse(  BOLD_pred, BOLD_target_fake );
        
    end
        
end

% save data
 save(fullfile(save_address , 'model_recovery'), 'performance');
 
 
 %% plot the result
 
 
 
 for dataset = 1:numdatasets
     
     % initate a figure for each dataset
     figure;set(gcf,'PaperType','a3')
     set(gca,'xtick',[])
     
     for roi = 1:numrois
         for model_idx = 1:nummodels
             
             % load loss_log
            performance( dataset, roi, model_idx, : );
             
             % subplot dataset, roi, idx
             idx = (roi-1)*nummodels + model_idx;
             subplot( numrois, nummodels, idx);
             bar(squeeze(performance( dataset, roi, model_idx, : )))
             show_title = sprintf( 'Dataset%d-V%d-M%d', dataset, roi, model_idx );
             ylim([0,2])
             title( show_title )
             
         end
         
         
     end
     
     % define filename and save the file
     save_figure = sprintf( 'figures/%s', load_option);
     if ~exist(save_figure, 'dir'), mkdir(save_figure); end
     filename = sprintf( 'figures/%s/paramter_recovery_mse-dataset%d-%s', load_option, dataset, target);
     savefig(filename)
     
     %print
     print_figure = sprintf( 'pdf/%s', load_option);
     if ~exist(print_figure, 'dir'), mkdir(print_figure); end
     filename = sprintf( 'pdf/%s/paramter_recovery_mse-dataset%d-%s', load_option, dataset, target);
     print(filename,'-dpng')
     
     
 end
 
 
