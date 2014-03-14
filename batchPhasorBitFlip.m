function batchPhasorBitFlip
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here
addpath('phasorAnalysis');


%% File handling
projectFolder = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Colorado Daysimeter data');
cropLogPath = fullfile(projectFolder,'phasorCropLog.xlsx');
fileDir = fullfile(projectFolder,'processedData');
resultsDir = fullfile(projectFolder,'results');
plotsDir = fullfile(projectFolder,'phasorPlots');

% Import the crop log
cropLog = struct;
[cropLog.subject,cropLog.startTime,cropLog.stopTime,...
    cropLog.startRm1,cropLog.stopRm1] = importCropLog(cropLogPath);

% Get a listing of all CDF files in the folder
fileList = dir([fileDir,filesep,'*.txt']);

%% Specify local data
lat = 39.068585;
lon = -108.565682;
GMToff = -7;

%% Preallocate output
nFile = numel(fileList);
output = struct;
output.subject = cell(nFile,1);
output.phasorMagnitude = cell(nFile,1);
output.phasorAngle = cell(nFile,1);
output.IS = cell(nFile,1);
output.IV = cell(nFile,1);
output.magnitudeWithHarmonics = cell(nFile,1);
output.magnitudeFirstHarmonic = cell(nFile,1);
output.daytimeCS = cell(nFile,1);
output.daytimeLux = cell(nFile,1);

%% Begin main loop
for i1 = 1:nFile
    %% Load file
    [time,Lux,~,CS,activity] = importBitFlip(fullfile(fileDir,fileList(i1).name));
    temp = regexp(fileList(i1).name,'(\d*)','tokens');
    subject = str2double(temp{1});
    output.subject{i1} = subject;
    time = time - 2/24; % Adjust from Eastern to Mountain time
    
    %% Match file to crop log
    cLog = cropLog.subject == subject;
    % Skip files with no crop log
    if sum(cLog) == 0
        continue;
    end
    startTime = cropLog.startTime(cLog);
    stopTime = cropLog.stopTime(cLog);
    startRm1 = cropLog.startRm1(cLog);
    stopRm1 = cropLog.stopRm1(cLog);
    crop = ~((time >= startTime) & (time <= stopTime));
    if ~isnan(startRm1)
        crop = crop | ((time >= startRm1) & (time <= stopRm1));
    end
    % Crop the data
    time(crop) = [];
    activity(crop) = [];
    CS(crop) = [];
    Lux(crop) = [];
    % Check for over cropping
    if isempty(time)
        warning(['Data is over cropped for dubject ',num2str(subject)]);
        continue;
    end
    
    %% Perform analysis
    % Run daytime light analysis
    [dayIdx,output.daytimeCS{i1},output.daytimeLux{i1}] =...
        daytimeLight(time,CS,Lux,lat,lon,GMToff);
    
    % Remove nighttime data
    CS(~dayIdx) = 0;
    activity(~dayIdx) = 0;
    
    % Run phasor analysis
    [output.phasorMagnitude{i1},output.phasorAngle{i1},...
        output.IS{i1},output.IV{i1},...
        output.magnitudeWithHarmonics{i1},...
        output.magnitudeFirstHarmonic{i1}] =...
        phasorAnalysis(time,CS,activity);
    
    %% Plot Data
    Title = ['GSA Subject ',num2str(subject)];
    PhasorReportNoDates(time,activity,CS,...
        output.phasorMagnitude{i1},output.phasorAngle{i1},...
        output.IS{i1},output.IV{i1},...
        output.magnitudeWithHarmonics{i1},...
        output.magnitudeFirstHarmonic{i1},Title);
    plotFile = fullfile(plotsDir,['noNightSubject',num2str(subject),'.pdf']);
    saveas(gcf,plotFile);
    close all;
end

%% Save output
outputPath = fullfile(resultsDir,['noNightPhasor_',datestr(now,'yyyy-mm-dd_HH-MM')]);
save([outputPath,'.mat'],'output');

% Make varNames pretty
uglyVarNames = fieldnames(output);
varNames = regexprep(uglyVarNames,'([^A-Z])([A-Z])','$1\r\n$2');
outputCell = dataset2cell(struct2dataset(output));
for i2 = 1:numel(varNames)
    outputCell{1,i2} = varNames{i2};
end
xlswrite([outputPath,'.xlsx'],outputCell);

close gcf
end

