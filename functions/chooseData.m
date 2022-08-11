function T = chooseData(quick_choice, optimizer, fittime)

%  A simple function to help select model and data
%
%  Args:
%       quick_choice: check the switch function below
%       optimizer:    use 'fmincon'
%       fittime:      usually 40 
%
%   Outputs:
%       T: a table of all fitting info
%

% dataset is [which_dataset (1-4) | which_roi (V1-V3)];
datasets = [1, 2, 3, 4];
roi_idx  = [1, 2, 3];
ROIs     = {'V1', 'V2', 'V3'};

% assign the model to the model struct 
models = cell(5, 1);
models{1} = contrastModel(optimizer, fittime);
models{2} = SOCModel(optimizer, fittime);
models{3} = oriSurroundModel(optimizer, fittime);
models{4} = normModel(optimizer, fittime);
models{5} = normVarModel(optimizer, fittime);

switch quick_choice
    % for model fitting
    case {'all', 'All'}; model_idx = [1, 2, 3, 5];
    case {'test'}; model_idx = [1, 3, 4, 5]; datasets = 2;
    case {'more'}; model_idx = [1, 2, 3, 4, 5];
    case {'CE'}; model_idx = 1;
    case {'SOC'}; model_idx = 2;
    case {'OTS'}; model_idx = 3;
    case {'DN'}; model_idx = 4;
    case {'NOA'}; model_idx = 5;
    
    % for figures
    case {'figure3'};   model_idx = 1; datasets = 1;
    case {'figure4'};   model_idx = 1; datasets = 1;
    case {'figure5'};   model_idx = 4; datasets = 1;
    case {'figure6'};   model_idx = 5; datasets = 1;
    case {'figure7'};   model_idx = 3; datasets = 1;
    case {'figure9'};   model_idx = 3; datasets  = 1;
    case {'figureS2a'}; model_idx = 3; datasets  = [1, 2, 3, 4];
    case {'figureS2b'}; model_idx = 1; datasets  = [1, 2, 3, 4];
    case {'figureS2c'}; model_idx = 4; datasets  = [1, 2, 3, 4];
    case {'figureS2d'}; model_idx = 5; datasets  = [1, 2, 3, 4];
    case {'figureS3a'}; model_idx = 3; datasets  = 2;
    case {'figureS3b'}; model_idx = 3; datasets  = 3;
    case {'figureS3c'}; model_idx = 3; datasets  = 4;
    case {'figureS4a'}; model_idx = 1; datasets  = 1;
    case {'figureS4b'}; model_idx = 1; datasets  = 2;
    case {'figureS4c'}; model_idx = 1; datasets  = 3;
    case {'figureS4d'}; model_idx = 1; datasets  = 4;
    case {'figureS5a'}; model_idx = 4; datasets  = 1;
    case {'figureS5b'}; model_idx = 4; datasets  = 2;
    case {'figureS5c'}; model_idx = 4; datasets  = 3;
    case {'figureS5d'}; model_idx = 4; datasets  = 4;
    case {'figureS6a'}; model_idx = 5; datasets  = 1;
    case {'figureS6b'}; model_idx = 5; datasets  = 2;
    case {'figureS6c'}; model_idx = 5; datasets  = 3;
    case {'figureS6d'}; model_idx = 5; datasets  = 4;
    case {'figureS7a'}; model_idx = [1, 3, 4, 5]; datasets  = 1;
    case {'figureS7b'}; model_idx = [1, 3, 4, 5]; datasets  = 2;
    case {'figureS7c'}; model_idx = [1, 3, 4, 5]; datasets  = 3;
    case {'figureS7d'}; model_idx = [1, 3, 4, 5]; datasets  = 4;
end

n = length(datasets) * length(ROIs) * length(model_idx);

dataset     = NaN(n,1);
roiNum      = NaN(n,1);
roiName     = cell(n,1);
modelNum    = NaN(n,1);
modelLoader = cell(n,1);

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
