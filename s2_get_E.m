
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

labelall = {1:50 , 1:48 , 1:39, 1:39};

%%  Set up the parameters

% add it to avoid creating e_ori again
mode = 'space';

n=128;
sfvec = 2^5/3;
o = linspace(0,pi, 9);
thetavec = o(1:end-1);
nF=length(sfvec);
nO=length(thetavec);

[ Gabor_c, Gabor_s]=makeGaborFilter(n, sfvec, thetavec);


%%
for which_data = 1 : length(datacell)
    
    % Select the dataset
    data     = datacell{which_data};
    labelVec = labelall{which_data};
    
    E_ori_sum = zeros(8, 9, length(labelVec));
    
    if which_data  == 2
        E_space_sum = nan( 680, 680, nO, 9, length( labelall{which_data} ) );
    else
        E_space_sum = nan( 480, 480, nO, 9, length( labelall{which_data} ) );
    end
    
    for ii= 1:length(labelVec)
        
        label = labelVec(ii)
        
        for ep = 1 : 9 % Each have 9 examples.
            
            % Since the dimensions are not the same
            if which_data > 2
                stimulus_i = data( : , : , ep , label );
                stimulus = imresize(stimulus_i, .5);
            else
                stimulus = data( : , : , ep, label );
            end
            
            size_s = size(stimulus , 1);
            
            
            %Pad the stimulus to avoid edge effect
            padstimulus=zeros(size_s + 80, size_s + 80);
            padstimulus(41:size_s + 40,41:size_s + 40)=stimulus;
            stimulus=padstimulus;
            
            % Filtering and rectification to get the CONTRAST of the image
            con = squeeze(Icontrast(stimulus, Gabor_c, Gabor_s, sfvec, thetavec)); %3 - D x , y , theta
            
            if strcmp( mode, 'orientation' ) == 1
                % Get the size of e_1
                size_con = size(con , 1);
                
                % Create a disk-like weight to prevent edge effect
                w = gen_disk( size( con ,  1 ) , size( con , 3 ) , 1);  %3 - D x , y , theta
                
                % Calculate E_ori for orientation-type model
                % Sum over space
                E_ori = squeeze(mean(mean(w.*con , 2 ), 1)); % 1- D theta
                
                % Store the data into a matrix
                E_ori_sum( : ,  ep , ii ) = E_ori';
                
            elseif strcmp( mode, 'space' ) == 1
                % Calculate E_space for space-type model
                % Assign the data into a matrix
                E_space_sum( : , : , : , ep , ii ) = con;
                
            end
        end
    end
    
    % We should have used a big matrix here, but holding extremely
    % large data require really decent configuration of the
    % computer (even hurt computer sometime), so I save each
    % dataset individually, and clear the variable to empty the
    % memory for future using.
    
    E_ori = E_ori_sum( : , : , labelall{which_data} );
    E_xy  = E_space_sum( : , : , : , :, labelall{which_data}   );
    
    
    fname = sprintf('E_ori_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'E_ori')
    fname = sprintf('E_xy_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'E_xy')
    
end




