function BatchGSAAnalysis
%CASEWESTERNANALYSIS Desciption goes here
%   Detailed description goes here

% Mark time of analysis
runTime = now;

%% Turn warning off
s1 = warning('off','MATLAB:linearinter:noextrap');
s2 = warning('off','MATLAB:xlswrite:AddSheet');

%% Enable paths to required subfunctions
addpath('phasorAnalysis','sleepAnalysis','IO','CDF');

%% Ask user what sleep time to use
sleepLogMode = menu('Select what sleep time mode to use','fixed','logs/dynamic');
if sleepLogMode == 1
    bedStr = input('Enter bed time (ex. 21:00): ','s');
    bedTokens = regexp(bedStr,'^(\d{1,2}):(\d\d)','tokens');
    fixedBedTime = str2double(bedTokens{1}{1})/24 + str2double(bedTokens{1}{2})/60/24;
    
    wakeStr = input('Enter wake time (ex. 07:00): ','s');
    wakeTokens = regexp(wakeStr,'^(\d{1,2}):(\d\d)','tokens');
    fixedWakeTime = str2double(wakeTokens{1}{1})/24 + str2double(wakeTokens{1}{2})/60/24;
else
    fixedBedTime = 0;
    fixedWakeTime = 0;
end

%% File handling
caseWesternHome = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Colorado Daysimeter data');
% Read in data from excel spreadsheet of dimesimeter/actiwatch info
indexPath = fullfile(caseWesternHome,'index.xlsx');
[subject, days, daysimStart, daysimEnd, daysimPath] = importIndex(indexPath);
% Import sleepLog
sleepLogPath = fullfile(caseWesternHome,'sleepLog.xlsx');
sleepLog = importSleepLog(sleepLogPath);

% Set an output location
saveDir = fullfile(caseWesternHome,'Analysis');
errorPath = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_error_log.txt']);

%% Creates a text file that records any errors in the data in the same path
% as the results
fid = fopen(errorPath,'w');
fprintf( fid, 'Error Report \r\n' );
fclose( fid );

%% Preallocate variables
lengthSub = length(subject);
% Preallocate phasor struct
phasorData = dataset;
phasorData.subject = subject;
phasorData.week = week;
phasorData.phasorMagnitude = zeros(lengthSub,1);
phasorData.phasorAngle = zeros(lengthSub,1);
phasorData.IS = zeros(lengthSub,1);
phasorData.IV = zeros(lengthSub,1);
phasorData.meanCS = zeros(lengthSub,1);
phasorData.magnitudeWithHarmonics = zeros(lengthSub,1);
phasorData.magnitudeFirstHarmonic = zeros(lengthSub,1);
phasorData.season = cell(lengthSub,1);
% Preallocate sleep struct
sleepData = dataset;
sleepData.subject = subject;
sleepData.season = cell(lengthSub,1);
sleepData.ActualSleep = cell(lengthSub,1);
sleepData.ActualSleepPercent = cell(lengthSub,1);
sleepData.ActualWake = cell(lengthSub,1);
sleepData.ActualWakePercent = cell(lengthSub,1);
sleepData.SleepEfficiency = cell(lengthSub,1);
sleepData.Latency = cell(lengthSub,1);
sleepData.SleepBouts = cell(lengthSub,1);
sleepData.WakeBouts = cell(lengthSub,1);
sleepData.MeanSleepBout = cell(lengthSub,1);
sleepData.MeanWakeBout = cell(lengthSub,1);
sleepData.actiIS = cell(lengthSub,1);
sleepData.actiIV = cell(lengthSub,1);
sleepData.userBedLogs = cell(lengthSub,1);
sleepData.calcBedLogs = cell(lengthSub,1);
sleepData.userUpLogs = cell(lengthSub,1);
sleepData.calcUpLogs = cell(lengthSub,1);

%% Perform vectorized calculations

% Set start and stop times for analysis
daysimStart(isnan(daysimStart)) = 0;
startTime = daysimStart;

% Determine the season
monthStr = datestr(startTime,'mm');
monthCell =  mat2cell(monthStr,ones(length(monthStr),1));
month = str2double(monthCell);
idxSeason = month < 3 | month >= 11; % true = winter, false = summer

%% Begin main loop
for i1 = 1:lengthSub
    % Creates a header title with information about the loop
    header = ['Subject: ',num2str(subject(i1)),...
              ' Week: ',num2str(week(i1)),...
              ' Iteration: ',num2str(i1),...
              ' of ',num2str(lengthSub)];
    disp(header);
    
    % Assign a text value for season
    if idxSeason(i1)
        phasorData.season{i1} = 'winter';
        sleepData.season{i1} = 'winter';
    else
        phasorData.season{i1} = 'summer';
        sleepData.season{i1} = 'summer';
    end

    % Check if Daysimeter file path is listed and exists
    if isempty(daysimPath{i1,1}) || (exist(daysimPath{i1,1},'file') ~= 2)
        if exist(daysimPath{i1,1},'file') ~= 2
            reportError(header,...
                ['Daysimeter file does not exist. File: ',daysimPath{i1,1}],...
                errorPath);
        end

        % Attempt to perform sleep analysis
        try
            subLog = checkSleepLog(sleepLog,subject(i1),dTime,AI,sleepLogMode,fixedBedTime,fixedWakeTime);
        catch err
            reportError(header,err.message,errorPath);
        end
        
        try
            [sleepData.ActualSleep{i1},sleepData.ActualSleepPercent{i1},...
                sleepData.ActualWake{i1},sleepData.ActualWakePercent{i1},...
                sleepData.SleepEfficiency{i1},sleepData.Latency{i1},...
                sleepData.SleepBouts{i1},sleepData.WakeBouts{i1},...
                sleepData.MeanSleepBout{i1},sleepData.MeanWakeBout{i1}] = ...
                AnalyzeFile(dTime,AI,subLog.bedtime,subLog.getuptime,true);

            dt = etime(datevec(dTime(2)),datevec(dTime(1)));
            [sleepData.actiIS{i1},sleepData.actiIV{i1}] = IS_IVcalc(AI,dt);
            
            if sleepLogMode == 2
                sleepData.userBedLogs{i1} = sum(subLog.bedlog);
                sleepData.calcBedLogs{i1} = numel(subLog.bedlog) - sleepData.userBedLogs{i1};
                sleepData.userUpLogs{i1} = sum(subLog.getuplog);
                sleepData.calcUpLogs{i1} = numel(subLog.getuplog) - sleepData.userUpLogs{i1};
            end
        catch err
            reportError(header,err.message,errorPath);
        end
        
        continue;
    else
        % Attempt to import the data
        try
            [dTime,CS,AI] = ...
                importData(daysimPath{i1,1},daysimSN(i1));
        catch err
            reportError(header,err.message,errorPath);
            continue;
        end
    end
    
    % Attempt to perform phasor analysis on the combined data
    try
        [phasorData.phasorMagnitude(i1),phasorData.phasorAngle(i1),...
            phasorData.IS(i1),phasorData.IV(i1),phasorData.meanCS(i1),...
            phasorData.magnitudeWithHarmonics(i1),...
            phasorData.magnitudeFirstHarmonic(i1)] =...
            phasorAnalysis(dTime,CS,AI);
    catch err
            reportError(header,err.message,errorPath);
    end
    
    % Attempt to perform sleep analysis
    try
        subLog = checkSleepLog(sleepLog,subject(i1),dTime,AI,sleepLogMode,fixedBedTime,fixedWakeTime);
    catch err
        reportError(header,err.message,errorPath);
    end
    
    try
        [sleepData.ActualSleep{i1},sleepData.ActualSleepPercent{i1},...
            sleepData.ActualWake{i1},sleepData.ActualWakePercent{i1},...
            sleepData.SleepEfficiency{i1},sleepData.Latency{i1},...
            sleepData.SleepBouts{i1},sleepData.WakeBouts{i1},...
            sleepData.MeanSleepBout{i1},sleepData.MeanWakeBout{i1}] = ...
            AnalyzeFile(dTime,AI,subLog.bedtime,subLog.getuptime,true,errorPath);
        
        dt = etime(datevec(dTime(2)),datevec(dTime(1)));
        [sleepData.actiIS{i1},sleepData.actiIV{i1}] = IS_IVcalc(AI,dt);
        if sleepLogMode == 2
            sleepData.userBedLogs{i1} = sum(subLog.bedlog);
            sleepData.calcBedLogs{i1} = numel(subLog.bedlog) - sleepData.userBedLogs{i1};
            sleepData.userUpLogs{i1} = sum(subLog.getuplog);
            sleepData.calcUpLogs{i1} = numel(subLog.getuplog) - sleepData.userUpLogs{i1};
        end
    catch err
        reportError(header,err.message,errorPath);
    end
end

%% Save output
outputFile = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_output.mat']);
save(outputFile,'phasorData','sleepData');
% Convert to Excel
phasorFile = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_phasor.xlsx']);
organizeExcel(phasorData,phasorFile);
sleepFile = fullfile(saveDir,[datestr(runTime,'yyyy-mm-dd_HH-MM'),...
    '_sleep.xlsx']);
organizeSleepExcel(sleepData,sleepFile);

%% Turn warnings back on
warning(s2);
warning(s1);
end