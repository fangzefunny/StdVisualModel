function plot_test3( pred, dataset, roi )

    %% set path

    [curPath, prevPath] = stdnormRootPath();

    % add path to the function
    addpath( genpath( fullfile( curPath, 'functions' )))

    % add path to the model
    addpath( genpath( fullfile( curPath, 'models' )))

    % add path to the plot tool
    addpath( genpath( fullfile( curPath, 'plot' )))

    switch dataset
        case { 1 , 2 }
            x1 = 1:5;  x2 = 6:10;
        case { 3 , 4, 5 }
            x1 = 1:4; y1 = 9:-1:6;
            x2 = 6:10; y2 = 5:-1:1;
    end

    % some important value
    plotwidth = 1.5;
    markersize = 4.5;
    target = 'target';
    num_pred = size( pred, 2);


    % load target data
    BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi );

    % check the num of stimuli
    num_stim =length( BOLD_target);
    stim_vec = [1:num_stim+1];
    target_vector = nan( 1, num_stim + 1);
    pred_vector = nan( size(pred));

    target_vector( x1) = BOLD_target( x1);
    target_vector( x2+1) = BOLD_target( x2);
    pred_vector( x1, :) = pred( x1, :);
    pred_vector( x2+1, :) = pred(x2, :);
    
    

    b = bar( stim_vec, target_vector);
    set( b,'Facecolor', [ .8, .8, .8],'Edgecolor', [.8, .8, .8]);
    hold on
    
    for ii = 1:num_pred
        gain = target_vector(1)/pred_vector(1, ii)
        print_vector = gain*pred_vector( :, ii);
        plot( stim_vec,  print_vector, '-o', ...
            'MarkerSize', markersize,...
            'LineWidth', plotwidth);
    end
   
    legend( {'BOLD','e,g=14.26,n=1', 's, g=216,n=1', 'sn, g=3.5e+06, n=2.4'})
    
end