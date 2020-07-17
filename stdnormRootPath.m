function [rootPath, prevPath ]=stdnormRootPath()
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

% This is the path for the prev folder 
deepth = 1;
fsep  = filesep;
pos_v = strfind(  rootPath, fsep );
prevPath = rootPath( 1:pos_v( length( pos_v ) - deepth + 1 ) - 1 );

return
