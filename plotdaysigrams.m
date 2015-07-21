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

mkdir(Paths.plots,'daysigrams-cs');
mkdir(Paths.plots,'daysigrams-lux');

dirCs = fullfile(Paths.plots,'daysigrams-cs');
dirLux = fullfile(Paths.plots,'daysigrams-lux');

nFiles = numel(cdfPathArray);
for i1 = 1:nFiles
    % Import data
    cdfData = daysimeter12.readcdf(cdfPathArray{i1});
    [absTime,relTime,epoch,light,activity,masks,subjectID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
%     absTime.localDateNum = absTime.localDateNum(masks.observation);
%     light.cs = light.cs(masks.observation);
%     light.illuminance = light.illuminance(masks.observation);
%     activity = activity(masks.observation);
%     masks.bed = masks.bed(masks.observation);
%     masks.compliance = masks.compliance(masks.observation);
%     masks.observation = masks.observation(masks.observation);
    
    locationID = subjectID;
    activity = zeros(size(activity));
    
    % Daysigram
    sheetTitle = ['GSA - ',displayLocation,' - ',displaySession,' - ',locationID];
    sheetTitle = regexprep(sheetTitle,'_','\\_');
    
    daysigramFileID = ['location',locationID,'_cs'];
    
    reports.daysigram.daysigram(1,sheetTitle,absTime.localDateNum,masks,activity,light.cs,'cs',[0,1],14,dirCs,daysigramFileID);
    
    daysigramFileID = ['location',locationID,'_lux'];
    
    reports.daysigram.daysigram(2,sheetTitle,absTime.localDateNum,masks,activity,light.illuminance,'lux',[0.01,10^5],14,dirLux,daysigramFileID);
    
end

end

