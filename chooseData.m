function [ alldataset ,  allmodel , alltype] = chooseData( data_mod , model_mod)
% This is a simple function to help select model

defaultdataset = {'Ca69_v1' , 'Ca05_v1' , 'K1_v1' , 'K2_v1' , 'Ca69_v2' , 'Ca05_v2' , 'K1_v2' , 'K2_v2' , 'Ca69_v3' , 'Ca05_v3' , 'K1_v3' , 'K2_v3'};
defaultmodel = {'contrast' ,  'normStd' , 'normVar' , 'normPower', ' SOC'};
defaulttype = {'orientation' , 'orientation' , 'orientation' , 'orientation'};

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
