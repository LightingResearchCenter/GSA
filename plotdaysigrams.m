function plotdaysigrams
%PLOTDAYSIGRAMS Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[cdfNameArray,cdfPathArray] = searchdir(Paths.editedData,'cdf');

nFiles = numel(cdfPathArray);
for i1 = 1:nFiles
    % Import data
    Data = ProcessCDF(cdfPathArray{i1});
    locationID = Data.GlobalAttributes.subjectID{1};
    logicalArray = logical(Data.Variables.logicalArray);
    complianceArray = logical(Data.Variables.complianceArray(logicalArray));
    timeArray = Data.Variables.time(logicalArray);
    activityArray = zeros(size(timeArray));
    csArray = Data.Variables.CS(logicalArray);
    illuminanceArray = Data.Variables.illuminance(logicalArray);
    
    % Daysigram
    sheetTitle = ['GSA - ',displayLocation,' - ',displaySession,' - ',locationID];
    
    daysigramFileID = ['location',locationID,'_cs'];
    generatedaysigram(sheetTitle,timeArray(complianceArray),...
        activityArray(complianceArray),csArray(complianceArray),...
        'cs',[0,1],14,Paths.plots,daysigramFileID);
    
    daysigramFileID = ['location',locationID,'_lux'];
    generatedaysigram(sheetTitle,timeArray(complianceArray),...
        activityArray(complianceArray),illuminanceArray(complianceArray),...
        'lux',[0.01,10^5],14,Paths.plots,daysigramFileID);
    
end

end

