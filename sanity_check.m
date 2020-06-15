%% clear the memory

clear all; close all; clc
%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot' )))
%% hyperparameter: each time, we only need to edit this section !!

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'target';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'noCross';  % save in which folder. value space: 'noCross', .....
cross_valid     = 'one';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.
dataset            = 3;
roi                      = 2;
model               = contrastModel(optimizer, fittime);
model_idx       = 3;
params             = [ nan, 5.6058,  -1.6928];%0.1124
checkparam_vector = 3%linspace(8, 13.1224, 10);%[-3, 0, 2, 3, 11.9] % linspace(0, 11, 5); % 
which_param       = 1;
landscape = true;


%% load data

% some important value 
fontsize = 9;
linewidth = 1.2;
plotwidth = 1.5;
markersize = 4.5;

% length of paramters
num = length(  checkparam_vector);

% load target data
BOLD_target = dataloader( prevPath, 'BOLD_target', target, dataset, roi );
 plot_BOLD( [], BOLD_target, dataset, roi, target, nan )


 % load the input stimuli
switch model.model_type
    case 'orientation'
        which_obj ='E_ori';
    case 'space'
        which_obj = 'E_xy';
end
E = dataloader( prevPath, which_obj, target, dataset, roi );

% check the num of stimuli
num_stim =length( BOLD_target);
stim_vec = [1:num_stim+1];

% create a big matrix to store predictions using different parameters
pred_matrix = nan( num_stim+1, num);
loss_matrix = nan( 1, num);
target_vector = nan( 1, num_stim + 1);


switch dataset
    case { 1 , 2 }
        x1 = 1:5;  x2 = 6:10; x3 = 35:38; x4 = 47:50;
        y1 = 1:5; y2 = 7:11;  y3 = 12:15; y4 = 17:20;
    case { 3 , 4 }
       y1 = 1:4; x1 = 9:-1:6;
       y2 = 6:10; x2 = 5:-1:1;
end

target_vector( y1) = BOLD_target( x1);
target_vector( y2) = BOLD_target( x2);

for param_idx = 1 : num
    
    % set up params
    params(which_param) = checkparam_vector( param_idx);
    
    % fix the parameter 
    model = model.fixparameters( model, params);
    
    % make prediction using the fixed parameter
    BOLD_pred = model.predict( model, E);
    
    % check the num of stimuli
    num_stim =length( BOLD_target);
    stim_vec = [1:num_stim+1];
    
 
    pred_matrix( y1, param_idx) = BOLD_pred( x1);
    pred_matrix( y2, param_idx) = BOLD_pred(x2);
    
    gain = target_vector( 1) / pred_matrix( 1, param_idx)
    pred_matrix( :, param_idx) = gain * pred_matrix( :, param_idx);
    BOLD_pred = gain * BOLD_pred;
    
    
    
    % calculate the rmse to quantify the goodness of fit
    loss_matrix( param_idx) = model.rmse( BOLD_pred, BOLD_target );
    
    
end

subplot( 1, 2, 1)
b = bar( stim_vec, target_vector); 
set( b,'Facecolor', [ .8, .8, .8],'Edgecolor', [.8, .8, .8]);
hold on 
for idx = 1:num
    plot( stim_vec, pred_matrix( :, idx), '-o', ...
            'MarkerSize', markersize,...
            'LineWidth', plotwidth);
end
legend( 'BOLD', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10')
title( 'prediction')
subplot( 1, 2, 2)
bar( 1:num, loss_matrix)

title( 'loss')

%% 

if landscape
    
    ns = 100;
    params = [ nan, nan, -1.9187];
    gains = linspace( .5, 5., ns);
    cs = linspace( 1, 18, ns);
    m = nan( ns, ns );
    
    for i = 1:length( gains)
        for j = 1:length(cs)
            params(2) = gains(i);
            params(1) = cs(j);
            
            % fix the parameter
            model = model.fixparameters( model, params);
            
            % make prediction using the fixed parameter
            BOLD_pred = model.predict( model, E);
            
            m( i, j) = model.rmse( BOLD_pred, BOLD_target );
            
            
        end
    end
    m = min( .6, m );
    figure;
    imagesc( m )
    colorbar
    xrange =[1:ns];
    yrange = [1:ns];
    set(gca, 'xtick', xrange );
    set(gca, 'ytick', yrange );
    set(gca, 'XTickLabel', round(cs, 3));
    set(gca, 'YTickLabel', round(gains, 3));
    xlabel( 'log c')
    ylabel( 'log g' )
    title( sprintf( 'Loss landscape of-dataset%d-roi%d-model%d', dataset, roi, model_idx ))
    
    param = [ 11.9, -2.6593,  -1.9187];
    % fix the parameter
    model = model.fixparameters( model, param);
    
    % make prediction using the fixed parameter
    BOLD_pred = model.predict( model, E);
    model.rmse( BOLD_pred, BOLD_target )
    
end

