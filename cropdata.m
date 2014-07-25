function cropdata
%CROPDATA Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
location = gui_locationselect;
session  = gui_sessionselect;

% Construct project paths
Paths = initializepaths(location,session);

% Perform cropping
cropping(Paths.originalData,Paths.editedData,Paths.logs);

end

