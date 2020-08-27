%% set up save path

[curPath, prevPath] = stdnormRootPath();

%% download the data

url = 'https://osf.io/ty24m/?action=download';
pth = fullfile(prevPath, 'Data.zip');
fname = websave(pth, url);
unzip(fname);


%% calculate roi mean 

save_address = fullfile(prevPath, 'Data', 'fMRIdata');
if ~exist(save_address, 'dir'), mkdir(save_address); end
addpath( genpath(save_address));

% Load Dataset 1

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

% Load Dataset 2 

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

% Load Dataset 3

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

% Load Dataset 4

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

%% calculate E

save_address = fullfile(prevPath, 'Data', 'E');
if ~exist(save_address, 'dir'), mkdir(save_address); end

for which_data = 1:4 % 4 data sets
    
    fprintf('Computing E_ori, E_xy, weight_E for dataset %d\n', which_data);
    
    % Load the stimuli
    fname = sprintf('stimuli-dataset%02d.mat', which_data);
    path=fullfile(prevPath, 'Data', 'Stimuli', fname);
    load(path, 'stimuli')
    labelVec = 1:size(stimuli, 4);
       
    % Compute energy (E) for models that pool over space (one value per
    %   orientation band per stimulus)
    E_ori = cal_E( stimuli, labelVec, 'orientation', which_data );
    fname = sprintf('E_ori_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'E_ori')
          
    % Compute energy (E) for models that pool over orientation (one value 
    %   per spatial position per stimulus)    
    
    % E numerator
    E_xy     = cal_E( stimuli, labelVec, 'space', which_data );
    fname = sprintf('E_xy_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'E_xy','-v7.3')
    
    % E_mean for SOC
    E_mean = cal_Emean( E_xy);
    fname = sprintf('E_mean_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'E_mean','-v7.3')
    
    % W_E denominator for orSurround
    weight_E = cal_WE( E_xy, labelVec);
    fname = sprintf('weight_E_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'weight_E','-v7.3')

    clear E_xy
    clear E_mean
    clear weight_E
end

