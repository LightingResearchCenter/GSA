function fixbyteshift
%FIXBYTESHIFT Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
plainLocation = gui_locationselect;
plainSession  = gui_sessionselect;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[cdfFileNameArray,cdfPathArray] = searchdir(Paths.editedData,'cdf');

for i1 = 1:numel(cdfPathArray)
    filePath = cdfPathArray{i1};
    newFilePath = fullfile(Paths.editedData,cdfFileNameArray{i1});
    byteshift(filePath,newFilePath);
end

end

