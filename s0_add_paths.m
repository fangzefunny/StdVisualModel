
% Access to the fold in this folder
addPaths()

function addPaths()
    addpath( genpath( fullfile( stdnormRootPath, 'analyses' )))
    addpath( genpath( fullfile( stdnormRootPath, 'functions' )))
    addpath( genpath( fullfile( stdnormRootPath, 'models' )))
    addpath( genpath( fullfile( stdnormRootPath, 'plot' )))
end