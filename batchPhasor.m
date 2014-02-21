function batchPhasor
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here
[parentDir,~,~] = fileparts(pwd);
CDFtoolkit = fullfile(parentDir,'LRC-CDFtoolkit');
addpath(CDFtoolkit,'phasorAnalysis');


%% File handling
projectFolder = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Colorado Daysimeter data');
cropLogPath = fullfile(projectFolder,'cropLog.xlsx');
cdfFolder = fullfile(projectFolder,'cdfData');
resultsFolder = fullfile(projectFolder,'results');

% Import the crop log
cropLog = struct;
[cropLog.subject,cropLog.startTime,cropLog.stopTime] = importCropLog(cropLogPath);

% Get a listing of all CDF files in the folder
cdfList = dir([cdfFolder,filesep,'*.cdf']);

%% Specify local data
lat = 39.068585;
lon = -108.565682;
GMToff = -7;

%% Preallocate output
nCDF = numel(cdfList);
output = struct;
output.phasorMagnitude = cell(nCDF,1);
output.phasorAngle = cell(nCDF,1);
output.IS = cell(nCDF,1);
output.IV = cell(nCDF,1);
output.magnitudeWithHarmonics = cell(nCDF,1);
output.magnitudeFirstHarmonic = cell(nCDF,1);
output.daytimeCS = cell(nCDF,1);
output.daytimeLux = cell(nCDF,1);

%% Begin main loop
for i1 = 1:nCDF
    %% Load CDF
    data = ProcessCDF(fullfile(cdfFolder,cdfList(i1).name));
    subject = str2double(data.GlobalAttributes.subjectID{1});
    time = data.Variables.time - 2/24; % Adjust from Eastern to Mountain time
    CS = data.Variables.CS;
    Lux = data.Variables.illuminance;
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
    CS(crop) = [];
    Lux(crop) = [];
    % Check for over cropping
    if isempty(time)
        warning(['Data is over cropped for dubject ',num2str(subject)]);
        continue;
    end
    
    %% Perform analysis
    % Run phasor analysis
    [output.phasorMagnitude{i1},output.phasorAngle{i1},...
        output.IS{i1},output.IV{i1},...
        output.magnitudeWithHarmonics{i1},...
        output.magnitudeFirstHarmonic{i1}] =...
        phasorAnalysis(time,CS,activity);
    
    % Run daytime light analysis
    [output.daytimeCS{i1},output.daytimeLux{i1}] =...
        daytimeLight(time,CS,Lux,lat,lon,GMToff);
    
end

%% Save output
outputPath = fullfile(resultsFolder,['phasor_',datestr(now,'yyyy-mm-dd_HH-MM')]);
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

