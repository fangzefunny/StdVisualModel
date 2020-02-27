function T = chooseData(  model_type )
% This is a simple function to help select model

% The input value means: selectioning one of the dataset: 
% 'all'
% 'orientation',
% 'space' 

% dataset is [which_dataset (1-4) | which_roi (V1-V3)];
datasets = 1;
ROIs     = {'V2'}; %'V2' 'V3'};

switch model_type
    case 'all'
        models   = {'contrast' ,  'normStd' , 'normVar' , 'normPower', 'SOC', 'ori_surround'};
        types    = {'orientation' , 'orientation' , 'orientation' , 'orientation', 'space', 'space' };
    case 'orientation'
        models   = {'contrast' ,  'normStd'};% , 'normVar' , 'normPower'};
        types    = {'orientation' , 'orientation'};% , 'orientation' , 'orientation' };
    case 'space'
        models   = { 'SOC', 'ori_surround'};
        types    = { 'space', 'space' };
end


n = length(datasets) * length(ROIs) * length(models);

dataset     = NaN(n,1);
roiNum      = NaN(n,1);
roiName     = cell(n,1);
modelNum    = NaN(n,1);
modelName   = cell(n,1);
typeName    = cell(n,1);

idx = 0;
for d = 1:length(datasets)
    for r = 1:length(ROIs)
        for m = 1:length(models)
             
            idx = idx+1;
        
            dataset(idx)     = d;
            roiNum(idx)      = r;
            roiName(idx)     = ROIs(r);
            modelNum(idx)    = m;
            modelName(idx)   = models(m);
            typeName(idx)    = types(m);

        end
    end
end

T = table(dataset, roiNum, roiName, modelNum, modelName, typeName);

end
