%% set path

[curPath, prevPath] = stdnormRootPath();
save_address = fullfile(prevPath, 'Data', 'fake', 'All stimulus classes');
if ~exist(save_address, 'dir'), mkdir(save_address); end

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot_tools' )))

%% choose data and hyperparameter

T = chooseData( 'orientation' );

len = size( T, 1 );

nfake = 9;
target = 'all';
datatype = 'no_cross';

%% start loop

for fake_idx = 1: nfake
    
    for job = 1: len
        
        % obtrain data index
        dataset = T.dataset( job );
        
        % obtrain  roi index
        roi = T.roiNum( job );
        
        % obain model index
        model_idx = T.modelNum(job);
        
        % display information to keep track
        display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
        disp( display )
        
        % load model
        model = T.modelLoader{model_idx};
        
        % obtain target parameter
        param_target = dataloader( prevPath, 'param', target, dataset, roi, datatype, model_idx);
        param = param_pool( model_idx, param_target );
        
        % fix the paramter
        model = model.fixparameters( model, param );
        
        % load the input stimuli
        switch model.model_type
            case 'orientation'
                data_type ='E_ori';
            case 'space'
                data_type = 'E_xy';
        end
        E = dataloader( prevPath, data_type, target, dataset, roi, 'old' );
        disp( size(E) )
        
        % predict the BOLD prediction as fake data
        BOLD_pred = model.predict( model, E );
        
        simulation.BOLD_pred = BOLD_pred;
        simulation.param = param;
        
        % save data
        save(fullfile(save_address , sprintf('simulation_data-%d_roi-%d_model-%d_sim-%d.mat',dataset, roi, model_idx, fake_idx )) , 'simulation');
        
    end
    
end
