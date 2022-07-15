%% Parse the hyperparameters

if ~exist('ds', 'var'), ds = 1; end

% the spatial frequency
filter_cpd = [.75, 1.5, 3, 6];
%% download the fmri data

% url= 'https://osf.io/xv8m2/download';
% pth = fullfile(stdnormRootPath, 'Data', 'Data.zip');
% fname = websave(pth, url);
% unzip( fname, fullfile(stdnormRootPath, 'Data'));

%% Prepare input for the Φ fn.

% save address 
save_address = fullfile(stdnormRootPath, 'Data', 'E');
if ~exist(save_address, 'dir'), mkdir(save_address); end

 % Tell the current process
fprintf('Computing E_ori, E_xy, Z for dataset %d\n', ds);

fname = sprintf('stimuli-dataset%02d_orig.mat', ds); 
path  = fullfile(stdnormRootPath, 'Data', 'Stimuli', fname);
load(path, 'stimuli');
% preprocess
stimuli  = double(stimuli);
stimuli  = stimuli./255 - .5;
labelVec = size(stimuli, 4);
[Gabor_c, Gabor_s] = get_Filters(stimuli, ds, filter_cpd);
[E_ori, E_xy] = cal_E(stimuli, ds, Gabor_c, Gabor_s);
% save E_ori 
fname = sprintf('E_ori_%02d.mat', ds);
save(fullfile(save_address, fname), 'E_ori')
% save E_xy 
fname = sprintf('E_xy_%02d.mat', ds);
save(fullfile(save_address, fname), 'E_xy','-v7.3')
% cal Z_xy and save 
Z = cal_Z(E_xy, labelVec);
fname = sprintf('Z_%02d.mat', ds);
save(fullfile(save_address, fname), 'Z','-v7.3')


