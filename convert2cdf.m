function convert2cdf
%CONVERT2CDF Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[infoNameArray,infoPathArray] = searchdir(Paths.originalData,'LOG.txt');
[dataNameArray,dataPathArray] = searchdir(Paths.originalData,'DATA.txt');

infoRootArray = regexprep(infoNameArray,'-LOG.txt','');
dataRootArray = regexprep(dataNameArray,'-DATA.txt'  ,'');

switch plainLocation
    case 'grandjunction'
        timeOffset = -7; %MST
    case 'portland'
        timeOffset = -8; %PST
    case 'seattle'
        timeOffset = -8; %PST
    otherwise
        timeOffset = -5; %EST
end

switch plainSession
    case 'summer'
        timeOffset = timeOffset + 1; %DST
end

timeOffset = timeOffset*60*60; % convert hours to seconds

for i1 = 1:numel(infoNameArray)
    idxData = strcmp(infoRootArray{i1},dataRootArray);
    if ~any(idxData)
        continue
    end
    currentInfoPath = infoPathArray{i1};
    currentDataPath = dataPathArray{idxData};
    
    WriteProcessedCDF(currentInfoPath,currentDataPath,Paths.originalData,timeOffset)
    
end

end

