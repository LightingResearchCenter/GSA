function batchaddtocrop
%BATCHADDTOCROP Summary of this function goes here
%   Detailed explanation goes here

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

cropLogPath = fullfile(projectDir,'summerCropLog.xlsx');

% Import the crop log
CropLog = importcroplog(cropLogPath);

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

for i1 = 1:nCdf
    % Construct the file path
    cdfPath = fullfile(cdfDir,listing(i1).name);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    subject        = str2double(DaysimeterData.GlobalAttributes.subjectID{1});
    timeArray      = DaysimeterData.Variables.time;
    logicalArray   = DaysimeterData.Variables.logicalArray;
    
    % Add extra cropping to logical array
    logicalArray = addextracropping(CropLog,subject,timeArray,logicalArray);
    
    % Assign the modified variables
    DaysimeterData.Variables.logicalArray = logicalArray;
    
    % Delete the original file so that it can be replaced
    delete(cdfPath);
    
    % Save new file
    RewriteCDF(DaysimeterData, cdfPath);
    
end


end

