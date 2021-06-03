function rootPath=stdnormRootPath()
% Return the path to the root StdVisualModel directory
%
% This function must reside in the directory at the base of the StdVisualModel
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(stdnormRootPath,'Data')

% This is the path for the current folder 
rootPath=which('stdnormRootPath');
rootPath=fileparts(rootPath);

