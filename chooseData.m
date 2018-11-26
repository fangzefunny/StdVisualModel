function [ alldataset ,  allmodel , alltype] = chooseData( data_mod , model_mod)
% This is a simple function to help select model

% dataset is [which_dataset (1-4) | which_roi (V1-V3)];
defaultdataset = {[1 1] , [2 1] , [3 1] , [4 1], [1 2] , [2 3] , [3 2] , [4 2],[1 3] , [2 3] , [3 3] , [4 3]};
defaultmodel = {'contrast' ,  'normStd' , 'normVar' , 'normPower', 'SOC'};
defaulttype = {'orientation' , 'orientation' , 'orientation' , 'orientation', 'space'};

switch data_mod
    case 'all'
        alldataset = defaultdataset;
    case 'v1'
        alldataset = defaultdataset( 1:4 );
    case 'v2'
        alldataset = defaultdataset( 5:8 );
    case 'v3'
        alldataset = defaultdataset( 9:12 );
end


switch model_mod
    case 'fit_all'
        allmodel = defaultmodel;
        alltype = defaulttype;
    case 'fit_ori'
        allmodel = defaultmodel( 1:4 );
        alltype = defaulttype( 1:4 );
    case 'fit_spa'
        allmodel = defaultmodel(5);
        alltype = defaulttype(5);
        
end
end
