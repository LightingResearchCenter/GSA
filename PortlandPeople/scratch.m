clear;
clc;


% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
addpath(CDFtoolkitDir);

% Specify directories
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_People_Data');

cdfDir = fullfile(projectDir,'summerEditedData');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

cdfPath = fullfile(cdfDir,listing(13).name);

% Load the data
DaysimeterData = ProcessCDF(cdfPath);
logicalArray = logical(DaysimeterData.Variables.logicalArray);
timeArray = DaysimeterData.Variables.time;
activityArray = DaysimeterData.Variables.activity;
csArray = DaysimeterData.Variables.CS;
subjectID = DaysimeterData.GlobalAttributes.subjectID{1};

logicalArray = adjustcrop(timeArray,logicalArray);


