function batchHourly
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here

%% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','GrandJunction_Colorado_site_data','Daysimeter_data');
cropLogPath = fullfile(projectDir,'phasorCropLog.xlsx');
fileDir = fullfile(projectDir,'processedData');
resultsDir = fullfile(projectDir,'results');
outputPath = fullfile(resultsDir,['hourlyAverage_',datestr(now,'yyyy-mm-dd_HH-MM'),'.xlsx']);

% Import the crop log
cropLog = struct;
[cropLog.subject,cropLog.startTime,cropLog.stopTime,...
    cropLog.startRm1,cropLog.stopRm1] = importCropLog(cropLogPath);

% Get a listing of all CDF files in the folder
fileList = dir([fileDir,filesep,'*.txt']);

%% Preallocate output
nFile = numel(fileList);
header = {'time MST','Lux','CLA','CS','activity'};


%% Begin main loop
for i1 = 1:nFile
    %% Load file
    [time,Lux,CLA,CS,activity] = importBitFlip(fullfile(fileDir,fileList(i1).name));
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
    CS(crop) = [];
    Lux(crop) = [];
    % Check for over cropping
    if isempty(time)
        warning(['Data is over cropped for dubject ',num2str(subject)]);
        continue;
    end
    
    %% Average data and convert to cell
    [hrTime,hrLux,hrCLA,hrCS,hrActivity] = hourlyAverage(time,Lux,CLA,CS,activity);
    
    % Convert time to text for Excel
    strTime = datestr(hrTime,'mm/dd/yyyy HH:MM');
    cellTime = cellstr(strTime);
    
    dataCell = [cellTime,num2cell(hrLux),num2cell(hrCLA),num2cell(hrCS),num2cell(hrActivity)];
    
    % Add header row
    outputCell = [header;dataCell];
    
    %% Save output
    sheet = ['subject ',num2str(subject)];
    xlswrite(outputPath,outputCell,sheet);

end

end

