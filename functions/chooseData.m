function T = chooseData(quick_choice, optimizer, fittime)
% This is a simple function to help select model

% The input value means: selectioning one of the dataset:
% 'all'
% 'orientation',
% 'space'

% dataset is [which_dataset (1-4) | which_roi (V1-V3)];
datasets = [1, 2, 3, 4];
roi_idx  = [1, 2, 3];
ROIs     = {'V1', 'V2', 'V3'};

models = cell(4, 1);
models{1} = contrastModel(optimizer, fittime);
models{2} = normCEModel(optimizer, fittime);
models{3} = normVarModel(optimizer, fittime);
models{4} = SOCModel(optimizer, fittime);
models{5} = oriSurroundModel(optimizer, fittime);
models{6} = normModel(optimizer, fittime);

switch quick_choice
    % for figures
    case {'figure3'}
        model_idx = 1;
        datasets = 1;
    case {'figure4'}
        model_idx = 1;
        datasets = 1;
    case {'figure5'}
        model_idx = 4;
        datasets = 1;
    case {'figure6'}
        model_idx = 5;
        datasets = 1;
    case {'figure7'}
        model_idx = 3;
        datasets  = 1;
    case {'figure9'}
        model_idx = 3;
        datasets  = 1;
    case {'figureS2a'}
        model_idx = 3;
        datasets  = [1, 2, 3, 4];
    case {'figureS2b'}
        model_idx = 1;
        datasets  = [1, 2, 3, 4];
    case {'figureS2c'}
        model_idx = 4;
        datasets  = [1, 2, 3, 4];
    case {'figureS2d'}
        model_idx = 5;
        datasets  = [1, 2, 3, 4];
    case {'figureS3a'}
        model_idx = 3;
        datasets  = 2;
    case {'figureS3b'}
        model_idx = 3;
        datasets  = 3;
    case {'figureS3c'}
        model_idx = 3;
        datasets  = 4;
    case {'figureS4a'}
        model_idx = 1;
        datasets  = 1;
    case {'figureS4b'}
        model_idx = 1;
        datasets  = 2;
    case {'figureS4c'}
        model_idx = 1;
        datasets  = 3;
    case {'figureS4d'}
        model_idx = 1;
        datasets  = 4;
    case {'figureS5a'}
        model_idx = 4;
        datasets  = 1;
    case {'figureS5b'}
        model_idx = 4;
        datasets  = 2;
    case {'figureS5c'}
        model_idx = 4;
        datasets  = 3;
    case {'figureS5d'}
        model_idx = 4;
        datasets  = 4;
    case {'figureS6a'}
        model_idx = 5;
        datasets  = 1;
    case {'figureS6b'}
        model_idx = 5;
        datasets  = 2;
    case {'figureS6c'}
        model_idx = 5;
        datasets  = 3;
    case {'figureS6d'}
        model_idx = 5;
        datasets  = 4;
    case {'figureS7a'}
        model_idx = [1, 3, 4, 5];
        datasets  = 1;
    case {'figureS7b'}
        model_idx = [1, 3, 4, 5];
        datasets  = 2;
    case {'figureS7c'}
        model_idx = [1, 3, 4, 5];
        datasets  = 3;
    case {'figureS7d'}
        model_idx = [1, 3, 4, 5];
        datasets  = 4;
        % for others
    case {'con'}
        model_idx = 1;
    case {'all', 'All'}
        model_idx = [1, 3, 4, 5];
    case {'more'}
        model_idx = [1, 2, 3, 4, 5, 6];
    case 'orientation'
        model_idx = [1, 3];
    case 'noOri'
        model_idx = [1, 3, 4];
    case {'SOC', 'soc'}
        model_idx = 4;
    case {'OTS'}; model_idx = 5;
    case 'noNOA'; model_idx = [1, 4, 5];
    case 'NOA';  model_idx = 3;
    case 'STD';  model_idx = 2;
    case 'no_model'; model_idx = NaN;
    case 'SOC_test'; model_idx = 4; datasets = 1;
    case 'OTS_test'; model_idx = 5; datasets = 1;
    case 'NCE_model'; model_idx = 2;
    case {'figureS8a'}; model_idx = [2, 3, 5]; datasets  = 1;
    case {'figureS8b'}; model_idx = [2, 3, 5]; datasets  = 2;
    case {'figureS8c'}; model_idx = [2, 3, 5]; datasets  = 3;
    case {'figureS8d'}; model_idx = [2, 3, 5]; datasets  = 4;
    case {'Ori_Model'}; model_idx = [2, 3, 5];
    case 'NCE_model2'; model_idx = 6;
    case 'tar-noCross'; model_idx = [1, 2, 3, 4, 5];
    case 'tar-noCross-m3-m5-m6'; model_idx = [3, 5, 6];
    case 'all-noCross-m1-ds1'; model_idx = 1; datasets  = 1;
    case 'all-noCross-m1-ds2'; model_idx = 1; datasets  = 2;
    case 'all-noCross-m1-ds3'; model_idx = 1; datasets  = 3;
    case 'all-noCross-m1-ds4'; model_idx = 1; datasets  = 4;
    case 'all-noCross-m2-ds1'; model_idx = 2; datasets  = 1;
    case 'all-noCross-m2-ds2'; model_idx = 2; datasets  = 2;
    case 'all-noCross-m2-ds3'; model_idx = 2; datasets  = 3;
    case 'all-noCross-m2-ds4'; model_idx = 2; datasets  = 4;
    case 'all-noCross-m3-ds1'; model_idx = 3; datasets  = 1;
    case 'all-noCross-m3-ds2'; model_idx = 3; datasets  = 2;
    case 'all-noCross-m3-ds3'; model_idx = 3; datasets  = 3;
    case 'all-noCross-m3-ds4'; model_idx = 3; datasets  = 4;
    case 'all-noCross-m4-ds1'; model_idx = 4; datasets  = 1;
    case 'all-noCross-m4-ds2'; model_idx = 4; datasets  = 2;
    case 'all-noCross-m4-ds3'; model_idx = 4; datasets  = 3;
    case 'all-noCross-m4-ds4'; model_idx = 4; datasets  = 4;
    case 'all-noCross-m5-ds1'; model_idx = 5; datasets  = 1;
    case 'all-noCross-m5-ds2'; model_idx = 5; datasets  = 2;
    case 'all-noCross-m5-ds3'; model_idx = 5; datasets  = 3;
    case 'all-noCross-m5-ds4'; model_idx = 5; datasets  = 4;
    case 'all-noCross-m6-ds1'; model_idx = 6; datasets  = 1;
    case 'all-noCross-m6-ds2'; model_idx = 6; datasets  = 2;
    case 'all-noCross-m6-ds3'; model_idx = 6; datasets  = 3;
    case 'all-noCross-m6-ds4'; model_idx = 6; datasets  = 4;
    case 'all-noCross-m3m5m6-ds1'; model_idx = [3, 5, 6]; datasets  = 1;
    case 'all-noCross-m3m5m6-ds2'; model_idx = [3, 5, 6]; datasets  = 2;
    case 'all-noCross-m3m5m6-ds3'; model_idx = [3, 5, 6]; datasets  = 3;
    case 'all-noCross-m3m5m6-ds4'; model_idx = [3, 5, 6]; datasets  = 4;
    case 'all-noCross-m2m3m6-ds1'; model_idx = [2, 3, 6]; datasets  = 1;
    case 'all-noCross-m2m3m6-ds2'; model_idx = [2, 3, 6]; datasets  = 2;
    case 'all-noCross-m2m3m6-ds3'; model_idx = [2, 3, 6]; datasets  = 3;
    case 'all-noCross-m2m3m6-ds4'; model_idx = [2, 3, 6]; datasets  = 4;    
    case 'all-noCross-m2m3m5m6-ds1'; model_idx = [2, 3, 5, 6]; datasets  = 1;
    case 'all-noCross-m2m3m5m6-ds2'; model_idx = [2, 3, 5, 6]; datasets  = 2;
    case 'all-noCross-m2m3m5m6-ds3'; model_idx = [2, 3, 5, 6]; datasets  = 3;   
    case 'all-noCross-m2m3m5m6-ds4'; model_idx = [2, 3, 5, 6]; datasets  = 4;
end


n = length(datasets) * length(ROIs) * length(model_idx);

dataset     = NaN(n,1);
roiNum      = NaN(n,1);
roiName     = cell(n,1);
modelNum    = NaN(n,1);
modelLoader   = cell(n,1);

idx = 0;
for d = 1:length(datasets)
    for r = 1:length(ROIs)
        for m = 1:length(model_idx)
            
            idx = idx+1;
            
            dataset(idx)     = datasets(d);
            roiNum(idx)      = roi_idx(r);
            roiName(idx)     = ROIs(r);
            modelNum(idx)    = model_idx(m);
            modelLoader{idx} = models{model_idx(m)};
            
        end
    end
end

T = table(dataset, roiNum, roiName, modelNum, modelLoader);

end
