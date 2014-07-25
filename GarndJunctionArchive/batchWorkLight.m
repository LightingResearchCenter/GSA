function batchWorkLight
%BATCHANALYSIS Summary of this function goes here
%   Detailed explanation goes here

%% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','GrandJunction_Colorado_site_data','Daysimeter_data');
% projectDir = 'data';
cropLogPath = fullfile(projectDir,'phasorCropLog.xlsx');
fileDir = fullfile(projectDir,'processedData');
% fileDir = projectDir;
resultsDir = fullfile(projectDir,'results');
% resultsDir = projectDir;

% Import the crop log
cropLog = struct;
[cropLog.subject,cropLog.startTime,cropLog.stopTime,...
    cropLog.startRm1,cropLog.stopRm1] = importCropLog(cropLogPath);

% Get a listing of all CDF files in the folder
fileList = dir([fileDir,filesep,'*.txt']);

%% Preallocate output
nFile = numel(fileList);
output = struct;
output.subject = cell(nFile,1);
output.workCS = cell(nFile,1);
output.workLux = cell(nFile,1);

%% Begin main loop
for i1 = 1:nFile
    %% Load file
    [time,Lux,~,CS,~] = importBitFlip(fullfile(fileDir,fileList(i1).name));
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
    
    %% Perform analysis
    [output.workCS{i1},output.workLux{i1}] = workLight(time,CS,Lux);
    
end

%% Save output
outputPath = fullfile(resultsDir,['workLight_',datestr(now,'yyyy-mm-dd_HH-MM')]);
save([outputPath,'.mat'],'output');

% Make varNames pretty
uglyVarNames = fieldnames(output);
varNames = regexprep(uglyVarNames,'([^A-Z])([A-Z])','$1\r\n$2');
outputCell = dataset2cell(struct2dataset(output));
for i2 = 1:numel(varNames)
    outputCell{1,i2} = varNames{i2};
end
xlswrite([outputPath,'.xlsx'],outputCell);

end

