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
plotFolder = fullfile(projectFolder,'plots');

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
output = struct;
output.line = [];
output.subject = [];
output.Date = {};
output.ActualSleep = {};
output.ActualSleepPercent = {};
output.ActualWake = {};
output.ActualWakePercent = {};
output.SleepEfficiency = {};
output.Latency = {};
output.SleepBouts = {};
output.WakeBouts = {};
output.MeanSleepBout = {};
output.MeanWakeBout = {};

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
    [tempLine,tempSubject,tempDate,tempActualSleep,tempActualSleepPercent,...
        tempActualWake,tempActualWakePercent,...
        tempSleepEfficiency,tempLatency,...
        tempSleepBouts,tempWakeBouts,...
        tempMeanSleepBout,tempMeanWakeBout] = ...
        AnalyzeFile(subject,time,activity,bedTime,getupTime,plotFolder);
    
    %% Combine variables
    output.line = [output.line;tempLine];
    output.subject = [output.subject;tempSubject];
    output.Date = [output.Date;tempDate];
    output.ActualSleep = [output.ActualSleep;tempActualSleep];
    output.ActualSleepPercent = [output.ActualSleepPercent;tempActualSleepPercent];
    output.ActualWake = [output.ActualWake;tempActualWake];
    output.ActualWakePercent = [output.ActualWakePercent;tempActualWakePercent];
    output.SleepEfficiency = [output.SleepEfficiency;tempSleepEfficiency];
    output.Latency = [output.Latency;tempLatency];
    output.SleepBouts = [output.SleepBouts;tempSleepBouts];
    output.WakeBouts = [output.WakeBouts;tempWakeBouts];
    output.MeanSleepBout = [output.MeanSleepBout;tempMeanSleepBout];
    output.MeanWakeBout = [output.MeanWakeBout;tempMeanWakeBout];
end

close all;

%% Save output
outputPath = fullfile(resultsFolder,['sleep_',datestr(now,'yyyy-mm-dd_HH-MM')]);
save([outputPath,'.mat'],'output');
organizeExcel([outputPath,'.mat'])
end

