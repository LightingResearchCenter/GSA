function fixallCDF
%FIXALLCDF Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[cdfNameArray,cdfPathArray] = searchdir(Paths.editedData,'cdf');

for i1 = 1:numel(cdfNameArray)
    reprocesscdf(cdfPathArray{i1},false);
end

end

