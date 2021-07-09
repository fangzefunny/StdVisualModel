function []=add_path()
    % Access to the fold in this folder
    addpath( genpath( fullfile( stdnormRootPath, 'functions' )))
    addpath( genpath( fullfile( stdnormRootPath, 'models' )))
    addpath( genpath( fullfile( stdnormRootPath, 'plot' )))
    