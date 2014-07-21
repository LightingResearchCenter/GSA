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
    'Daysimeter_People_Data');

cdfDir = fullfile(projectDir,'summerEditedData');

printDir = fullfile(projectDir,'summerDaysigrams');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Create Daysigrams
% Preallocate variables
lightMeasure = 'cs';
lightRange = [0,1];
nDaysPerSheet = 8;
for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    logicalArray = logical(DaysimeterData.Variables.logicalArray);
    timeArray = DaysimeterData.Variables.time(logicalArray);
    activityArray = DaysimeterData.Variables.activity(logicalArray);
    csArray = DaysimeterData.Variables.CS(logicalArray);
    subjectID = DaysimeterData.GlobalAttributes.subjectID{1};
    
    if numel(timeArray) < 24
        continue;
    end
    
    sheetTitle = ['GSA (Portland, Oregon) Summer Subject: ',subjectID];
    fileID = ['sub',subjectID];
    
    % Generate the Daysigram
    generatereport(sheetTitle,timeArray,activityArray,csArray,...
        lightMeasure,lightRange,nDaysPerSheet,printDir,fileID);
end

end