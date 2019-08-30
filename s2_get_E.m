
clear all; close all; clc

%% Introduction

% This script is the second step, to calculate the energy as the imput of
% our later model;

save_address = fullfile(stdnormRootPath, 'Data', 'E');
if ~exist(save_address, 'dir'), mkdir(save_address); end

%% Load the data
datacell = cell(1,4);
for ii = 1:4
    fname = sprintf('stimuli-dataset%02d.mat', ii);
    tmp = load(fname, 'stimuli');
    datacell{ii} = double(tmp.stimuli)./255 - .5; clear tmp
end

labelall = {1:50 , 1:48, 1:39, 1:39};

%%  Set up the parameters

% add it to avoid creating e_ori again
mode = 'space';

%%
for which_data = 1: length(datacell)
    
    % Select the dataset
    data     = datacell{which_data};
    labelVec = labelall{which_data};
    
    
    switch mode
        case 'orientation'
            E_ori = cal_E( data, labelVec, mode, which_data );
            
        case 'space'
            E_space_sum = cal_E( data, labelVec, mode, which_data );
            weight_E_sum = cal_WE( E_space_sum, labelVec, which_data );
            
    end

    % We should have used a big matrix here, but holding extremely
    % large data require really decent configuration of the
    % computer (even hurt computer sometime), so I save each
    % dataset individually, and clear the variable to empty the
    % memory for future using.
    
    if strcmp( mode, 'orientation' ) == 1
        E_ori = E_ori_sum( : , : , labelall{which_data} );
        fname = sprintf('E_ori_%02d.mat', which_data);
        save(fullfile(save_address, fname), 'E_ori')
        
    elseif strcmp( mode, 'space' ) == 1
        % E numerator 
        E_xy  = E_space_sum( : , : , : , :, 1:10);%labelall{which_data}   );
        fname = sprintf('E_xy_%02d.mat', which_data);
        save(fullfile(save_address, fname), 'E_xy','-v7.3')
        % W_E denominator
        weight_E  = weight_E_sum( : , : , : , :, 1:10);%labelall{which_data}); 
        fname = sprintf('weight_E_%02d.mat', which_data);
        save(fullfile(save_address, fname), 'weight_E','-v7.3')
    end
    clear E_space_sum
    clear E_xy
    clear weight_E_sum
    claer weight_E
end




