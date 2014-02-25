function batchSleep
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here
[parentDir,~,~] = fileparts(pwd);
CDFtoolkit = fullfile(parentDir,'LRC-CDFtoolkit');
DaysimeterSleepAlgorithm = fullfile(parentDir,'DaysimeterSleepAlgorithm');
addpath(CDFtoolkit,DaysimeterSleepAlgorithm);


%% File handling
projectFolder = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Colorado Daysimeter data');
sleepLogPath = fullfile(projectFolder,'sleepLog.xlsx');
cropLogPath = fullfile(projectFolder,'cropLog.xlsx');
cdfFolder = fullfile(projectFolder,'cdfData');
resultsFolder = fullfile(projectFolder,'results');

% Import the sleep log
sleepLog = struct;
[sleepLog.subject,sleepLog.bedTime,sleepLog.getupTime] = importSleepLog(sleepLogPath);

% Import the crop log
cropLog = struct;
[cropLog.subject,cropLog.startTime,cropLog.stopTime] = importCropLog(cropLogPath);

% Get a listing of all CDF files in the folder
cdfList = dir([cdfFolder,filesep,'*.cdf']);

%% Preallocate output
nCDF = numel(cdfList);
output = cell(nCDF,1);

%% Begin main loop
for i1 = 1:nCDF
    %% Load CDF
    data = ProcessCDF(fullfile(cdfFolder,cdfList(i1).name));
    subject = str2double(data.GlobalAttributes.subjectID{1});
    time = data.Variables.time - 2/24; % Adjust from Eastern to Mountain Time
    activity = data.Variables.activity;
    
    %% Match file to crop log
    cLog = cropLog.subject == subject;
    % Skip files with no crop log
    if sum(cLog) == 0
        continue;
    end
    startTime = cropLog.startTime(cLog);
    stopTime = cropLog.stopTime(cLog);
    crop = ~((time >= startTime) & (time <= stopTime));
    % Crop the data
    time(crop) = [];
    activity(crop) = [];
    % Check for over cropping
    if isempty(time)
        warning(['Data is over cropped for dubject ',num2str(subject)]);
        continue;
    end
    
    %% Match file to sleep log
    sLogs = sleepLog.subject == subject;
    % Skip files with no sleep log
    if sum(sLogs) == 0
        continue;
    end
    bedTime = sleepLog.bedTime(sLogs);
    getupTime = sleepLog.getupTime(sLogs);
    
    %% Perform analysis
    % Run sleep analysis
    output{i1} = ...
        AnalyzeFile(subject,time,activity,bedTime,getupTime);
    
end

%% Save output
outputPath = fullfile(resultsFolder,['sleep_',datestr(now,'yyyy-mm-dd_HH-MM')]);
save([outputPath,'.mat'],'output');
organizeExcel([outputPath,'.mat'])
end

