function batchSleepBitFlip
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here
[parentDir,~,~] = fileparts(pwd);
DaysimeterSleepAlgorithm = fullfile(parentDir,'DaysimeterSleepAlgorithm');
addpath(DaysimeterSleepAlgorithm);


%% File handling
projectFolder = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Colorado Daysimeter data');
sleepLogPath = fullfile(projectFolder,'sleepLog.xlsx');
cropLogPath = fullfile(projectFolder,'cropLog.xlsx');
fileFolder = fullfile(projectFolder,'processedData');
resultsFolder = fullfile(projectFolder,'results');

% Import the sleep log
sleepLog = struct;
[sleepLog.subject,sleepLog.bedTime,sleepLog.getupTime] = importSleepLog(sleepLogPath);

% Import the crop log
cropLog = struct;
[cropLog.subject,cropLog.startTime,cropLog.stopTime] = importCropLog(cropLogPath);

% Get a listing of all edited files in the folder
fileList = dir([fileFolder,filesep,'*Processed.txt']);

%% Preallocate output
nFile = numel(fileList);
output = cell(nFile,1);

%% Begin main loop
for i1 = 1:nFile
    %% Load File
    [time,~,~,~,activity] = importBitFlip(fullfile(fileFolder,fileList(i1).name));
    temp = regexp(fileList(i1).name,'(\d*)','tokens');
    subject = str2double(temp{1});
    time = time - 2/24; % Adjust from Eastern to Mountain Time
    
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

