function plot_test2( pred, dataset, roi )

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
            y1 = 1:5; y2 = 7:11;
        case { 3 , 4 }
           y1 = 1:4; x1 = 9:-1:6;
           y2 = 6:10; x2 = 5:-1:1;
    end

    % some important value
    plotwidth = 1.5;
    markersize = 4.5;
    target = 'target';


    % load target data
    BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi );

    % check the num of stimuli
    num_stim =length( BOLD_target);
    stim_vec = [1:num_stim+1];
    target_vector = nan( 1, num_stim + 1);
    pred_vector = nan( 1, num_stim + 1);
    

    target_vector( y1) = BOLD_target( x1);
    target_vector( y2) = BOLD_target( x2);
    pred_vector( y1) = pred( x1);
    pred_vector( y2) = pred(x2);
    gain = mean(target_vector(1))/mean(pred_vector(1));
    pred_vector = gain*pred_vector;

    b = bar( stim_vec, target_vector);
    set( b,'Facecolor', [ .8, .8, .8],'Edgecolor', [.8, .8, .8]);
    hold on
    plot( stim_vec,  pred_vector, '-o', ...
        'MarkerSize', markersize,...
        'LineWidth', plotwidth);
   
    for ii = y1
        ssvec = stim_vec(ii: ii+6);
        plot( ssvec, ones(size(ssvec)) .*pred_vector(ii), '--');
    end
    
    title(sprintf('when gain is %.2d', gain))
end