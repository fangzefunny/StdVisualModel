
% Access to the fold in this folder
add_path()

function []=add_path()
    addpath( genpath( fullfile( stdnormRootPath, 'functions' )))
    addpath( genpath( fullfile( stdnormRootPath, 'models' )))
    addpath( genpath( fullfile( stdnormRootPath, 'plot' )))
end