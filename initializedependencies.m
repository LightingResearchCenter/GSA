function initializedependencies
%INITIALIZEDEPENDENCIES Add necessary repos to working path
%   Detailed explanation goes here

% Enable dependecies
% Find full path to github directory
[githubDir,~,~] = fileparts(pwd);

% Construct repo paths
circadianPath = fullfile(githubDir,'circadian');

% Enable repos
addpath(circadianPath);


end

