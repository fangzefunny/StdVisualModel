clear; close all; 

% This script creates a summary of ROI data from the voxel data

%%
[curPath, prevPath] = stdnormRootPath();

save_address = fullfile(prevPath, 'Data', 'fMRIdata');
addpath( genpath(save_address));
%% Load Dataset 1 (Catherine 06-19)

load('dataset01');
load('dataset01');

roiBetamn = roiBetas.roiBetamn;
roiBetase = roiBetas.roiBetase;

v_mean = [];
BOLD_se = [];

% v1 mean ( voxel _ mean _ dataset)
v_mean( 1 , : ) = roiBetamn{11};
BOLD_se( 1, :) = roiBetase{11};

% v2 mean 
v_mean( 2 , : ) = roiBetamn{12};
BOLD_se( 2, :) = roiBetase{12};

% v3 mean
v_mean( 3 , : ) = roiBetamn{13};
BOLD_se( 3, :) = roiBetase{13};

% save
save(fullfile(save_address , 'dataset01'), 'v_mean', '-append') 
save(fullfile(save_address , 'dataset01'), 'BOLD_se', '-append') 

% delete the variable to save up memory 
clear ( 'roiBetas')

%% Load Dataset 2 (Catherine 10-05)

load('dataset02'); 
load('dataset02');

roiBetamn = roiBetas.roiBetamn;
roiBetase = roiBetas.roiBetase;

v_mean = [];
BOLD_se = [];

% v1 mean 
v_mean( 1 , : ) = (roiBetamn{1} + roiBetamn{5})./2;
BOLD_se( 1 , : ) = (roiBetase{1} + roiBetase{5})./2;

% v2 mean 
v_mean( 2 , : ) = (roiBetamn{2} + roiBetamn{6})./2;
BOLD_se( 2 , : ) = (roiBetase{2} + roiBetase{6})./2;

% v3 mean
v_mean( 3 , : ) = (roiBetamn{3} + roiBetamn{7})./2;
BOLD_se( 3 , : ) = (roiBetase{3} + roiBetase{7})./2;

% save
save(fullfile(save_address , 'dataset02'), 'v_mean', '-append') 
save(fullfile(save_address , 'dataset02'), 'BOLD_se', '-append') 

% delete the variable to save up memory 
clear ( 'roiBetas')

%% Load Dataset 3 (Kendrick dataset 3)

% Choose the right stimuli we need 
labelVec_K = [[70:1:99],[107:1:115]];

load('dataset03', 'betamn', 'roi', 'betase' );


v_mean = [];
BOLD_se = [];

% v1 mean
v_mean( 1 , : ) = mean(betamn(roi==2 , labelVec_K));
BOLD_se( 1, :) = mean( betase(roi==2, labelVec_K));

% v2 mean 
v_mean( 2 , : ) = mean(betamn(roi==3 , labelVec_K));
BOLD_se( 2, :) = mean( betase(roi==3, labelVec_K));

% v3 mean 
v_mean( 3 , : ) = mean(betamn(roi==4 , labelVec_K));
BOLD_se( 3, : ) = mean( betase(roi==4, labelVec_K));

% save 
save(fullfile(save_address , 'dataset03'), 'v_mean', '-append') 
save(fullfile(save_address , 'dataset03'), 'BOLD_se', '-append') 

%% Load Dataset 4 (Kendrick dataset 4)

% Choose the right stimuli we need 
labelVec_K = [[70:1:99],[107:1:115]];

load('dataset04', 'betamn', 'roi', 'betase' );


v_mean = [];
BOLD_se = [];

% v1 mean
v_mean( 1 , : ) = mean(betamn(roi==2 , labelVec_K));
BOLD_se( 1, :) = mean( betase(roi==2, labelVec_K));

% v2 mean 
v_mean( 2 , : ) = mean(betamn(roi==3 , labelVec_K));
BOLD_se( 2, :) = mean( betase(roi==3, labelVec_K));

% v3 mean 
v_mean( 3 , : ) = mean(betamn(roi==4 , labelVec_K));
BOLD_se( 3, : ) = mean( betase(roi==4, labelVec_K));


% save 
save(fullfile(save_address , 'dataset04'), 'v_mean', '-append') 
save(fullfile(save_address , 'dataset04'), 'BOLD_se', '-append') 



