% add path to all folders
add_path()

% download the fmri data
url= 'https://osf.io/xv8m2/download';
pth = fullfile(stdnormRootPath, 'Data', 'Data.zip');
fname = websave(pth, url);
unzip( fname);

% calculate E
save_address = fullfile(stdnormRootPath, 'Data', 'E');
if ~exist(save_address, 'dir'), mkdir(save_address); end

for which_data = 1:4 % 4 data sets
    
    % Tell the current process
    fprintf('Computing E_ori, E_xy, weight_E for dataset %d\n', which_data);
    
    % Load the stimuli
    fname = sprintf('stimuli-dataset%02d.mat', which_data);
    path=fullfile(stdnormRootPath, 'Data', 'Stimuli', fname);
    load(path, 'stimuli')
    labelVec = 1:size(stimuli, 4);
       
    % Compute energy (E) for models that pool over space 
    % (one value per orientation band per stimulus)
    E_ori = cal_E( stimuli, labelVec, 'orientation', which_data );
    fname = sprintf('E_ori_%02d.mat', which_data);
    save(fullfile(save_address, fname), 'E_ori')
          
    % Compute energy (E) for models that pool over orientation 
    % (one value per spatial position per stimulus)    
    
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

