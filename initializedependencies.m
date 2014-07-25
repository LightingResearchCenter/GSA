function initializedependencies
%INITIALIZEDEPENDENCIES Add necessary repos to working path
%   Detailed explanation goes here

% Find full path to github directory
[githubDir,~,~] = fileparts(pwd);

% Contruct repo paths
cdfPath         = fullfile(githubDir,'LRC-CDFtoolkit');
daysigramPath   = fullfile(githubDir,'DaysigramReport');
croppingPath    = fullfile(githubDir,'DaysimeterCropToolkit');

% Enable repos
addpath(cdfPath,daysigramPath,croppingPath);

end

