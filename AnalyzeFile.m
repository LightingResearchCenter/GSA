function [Line,Subject,Date,ActualSleep,ActualSleepPercent,ActualWake,...
    ActualWakePercent,SleepEfficiency,Latency,SleepBouts,WakeBouts,...
    MeanSleepBout,MeanWakeBout] = AnalyzeFile(subject,Time,Activity,bedTime,wakeTime,plotFolder)

% Set analysis start and end times
analysisStartTime = bedTime - 20/60/24;
analysisEndTime = wakeTime + 20/60/24;

% Find analysis times outside of data
idx1 = (analysisStartTime < Time(1)) | (analysisStartTime > Time(end));
idx2 = (analysisEndTime   < Time(1)) | (analysisEndTime   > Time(end));
idx3 = idx1 | idx2;

% Remove times out of range
bedTime(idx3) = [];
wakeTime(idx3) = [];
analysisStartTime(idx3) = [];
analysisEndTime(idx3) = [];

nNights = numel(bedTime);

% Find maximum activity
maxActi = max(Activity);

% Calculate Epoch to the nearest second
epoch = round(mean(diff(Time)*24*60*60));

%% Preallocate sleep parameters
Line = zeros(nNights,1);
Subject = zeros(nNights,1);
Date = cell(nNights,1);
ActualSleep = cell(nNights,1);
ActualSleepPercent = cell(nNights,1);
ActualWake = cell(nNights,1);
ActualWakePercent = cell(nNights,1);
SleepEfficiency = cell(nNights,1);
Latency = cell(nNights,1);
SleepBouts = cell(nNights,1);
WakeBouts = cell(nNights,1);
MeanSleepBout = cell(nNights,1);
MeanWakeBout = cell(nNights,1);

dateFormat = 'dd-mmm-yy';

plot(Time,Activity);
datetick2;
title({['Subject ',num2str(subject)];...
        [datestr(Time(1),dateFormat),' - ',datestr(Time(end),dateFormat)]});
hold on;

%% Call function to calculate sleep parameters for each day
for i1 = 1:nNights
    Line(i1) = subject + i1/10;
    Subject(i1) = subject;
    Date{i1} = datestr(floor(analysisStartTime(i1)),dateFormat);
    
    patch([analysisStartTime(i1),analysisStartTime(i1),...
            analysisEndTime(i1),analysisEndTime(i1)],...
            [0,maxActi,maxActi,0],'r','FaceAlpha',.5);
    
    try
        param = fullSleepAnalysis(Time,Activity,epoch,...
                analysisStartTime(i1),analysisEndTime(i1),...
                bedTime(i1),wakeTime(i1),'auto');
    catch err
        display(err.message);
        continue;
    end
        
    ActualSleep{i1} = param.actualSleepTime;
    ActualSleepPercent{i1} = param.actualSleepPercent;
    ActualWake{i1} = param.actualWakeTime;
    ActualWakePercent{i1} = param.actualWakePercent;
    SleepEfficiency{i1} = param.sleepEfficiency;
    Latency{i1} = param.sleepLatency;
    SleepBouts{i1} = param.sleepBouts;
    WakeBouts{i1} = param.wakeBouts;
    MeanSleepBout{i1} = param.meanSleepBoutTime;
    MeanWakeBout{i1} = param.meanWakeBoutTime;
    
    clear param;
end
plotName = ['sub',num2str(subject),'_',datestr(Time(1),'yyyy-mm-dd'),'.png'];
saveas(gcf,fullfile(plotFolder,plotName));
hold off;

end