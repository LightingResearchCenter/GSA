function batchdaysigram
% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
DaysigramToolkit = fullfile(parentParentDir,'DaysigramReport');
addpath(CDFtoolkitDir,DaysigramToolkit);

% Specify directories
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_Stick_and_Window_data');

cdfDir = fullfile(projectDir,'editedData');

printDir = fullfile(projectDir,'daysigrams');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Find the useable durations
% Preallocate variables
duration = zeros(nCdf,1);
daysigramDuration = zeros(nCdf,1);

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    logicalArray = logical(DaysimeterData.Variables.logicalArray);
    timeArray = DaysimeterData.Variables.time(logicalArray);
    duration(i1) = timeArray(end) - timeArray(1);
    daysigramDuration(i1) = ceil(timeArray(end)) - floor(timeArray(1));
end

display(['Min  duration: ',num2str(min(duration))]);
display(['Mean duration: ',num2str(mean(duration))]);
display(['Max  duration: ',num2str(max(duration))]);
display('');
daysigramDuration = max(daysigramDuration);
display(['Daysigram duration: ',num2str(daysigramDuration)]);

% Create Daysigrams
% Preallocate variables
lightMeasure = 'cs';
lightRange = [0,1];
nDaysPerSheet = ceil(daysigramDuration/2);
for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    logicalArray = logical(DaysimeterData.Variables.logicalArray);
    timeArray = DaysimeterData.Variables.time(logicalArray);
    activityArray = DaysimeterData.Variables.activity(logicalArray);
    csArray = DaysimeterData.Variables.CS(logicalArray);
    locationID = DaysimeterData.GlobalAttributes.subjectID{1};
    
    sheetTitle = ['GSA (Portland, Oregon) ',locationID];
    fileID = locationID;
    
    % Generate the Daysigram
    generatereport(sheetTitle,timeArray,activityArray,csArray,...
        lightMeasure,lightRange,nDaysPerSheet,printDir,fileID);
end

end