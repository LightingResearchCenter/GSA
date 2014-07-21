function batchsleep
% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
SleepToolkit = fullfile(parentParentDir,'DaysimeterSleepAlgorithm');
addpath(CDFtoolkitDir,SleepToolkit);

% Specify directories
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_People_Data');
cdfDir = fullfile(projectDir,'summerEditedData');
resultsDir = fullfile(projectDir,'summerResults');
resultsName = [datestr(now,'yyyy-mm-dd_HHMM'),'_SleepAnalysis'];
resultsPath = fullfile(resultsDir,resultsName);
bedLogPath = fullfile(projectDir,'summerBedLog.xlsx');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Import the bed log
BedLog = importbedlog(bedLogPath);

% Preallocate variables
Output = struct(...
    'subject'               , {[]} ,...
    'night'                 , {[]} ,...
    'actualSleepTimeMins',    {[]},...
    'actualSleepPercent',     {[]},...
    'actualWakeTimeMins',     {[]},...
    'actualWakePercent',      {[]},...
    'sleepEfficiency',        {[]},...
    'sleepOnsetLatencyMins',  {[]},...
    'sleepBouts',             {[]},...
    'wakeBouts',              {[]},...
    'meanSleepBoutTimeMins',  {[]},...
    'meanWakeBoutTimeMins',   {[]});

ii = 1;
for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    logicalArray = logical(DaysimeterData.Variables.logicalArray);
    timeArray = DaysimeterData.Variables.time(logicalArray);
    activityArray = DaysimeterData.Variables.activity(logicalArray);
    subject = str2double(DaysimeterData.GlobalAttributes.subjectID{1});
    
    % Skip files with not enough useable data
    if numel(timeArray) < 24
        warning([listing(i1).name,' skipped due to insufficient data.']);
        continue;
    end
    
    % Select the corresponding bed log
    try
        [bedTimeArray,riseTimeArray] = selectbedlog(BedLog,subject);
    catch err
        warning(err.message);
        continue;
    end
    
    analysisStartTimeArray = bedTimeArray  - 20/(60*24);
    analysisEndTimeArray   = riseTimeArray + 20/(60*24);
    
    for i2 = 1:numel(bedTimeArray)
        % Perform analysis

        Sleep = sleepAnalysis(timeArray,activityArray,...
        analysisStartTimeArray(i2),analysisEndTimeArray(i2),...
        bedTimeArray(i2),riseTimeArray(i2),'auto');

        % Assign results to output struct
        Output(ii,1).subject               = subject;
        Output(ii,1).night                 = i2;
        
        Output(ii,1).actualSleepTimeMins    = Sleep.actualSleepTime;
        Output(ii,1).actualSleepPercent     = Sleep.actualSleepPercent;
        Output(ii,1).actualWakeTimeMins     = Sleep.actualWakeTime;
        Output(ii,1).actualWakePercent      = Sleep.actualWakePercent;
        Output(ii,1).sleepEfficiency        = Sleep.sleepEfficiency;
        Output(ii,1).sleepOnsetLatencyMins  = Sleep.sleepLatency;
        Output(ii,1).sleepBouts             = Sleep.sleepBouts;
        Output(ii,1).wakeBouts              = Sleep.wakeBouts;
        Output(ii,1).meanSleepBoutTimeMins	= Sleep.meanSleepBoutTime;
        Output(ii,1).meanWakeBoutTimeMins	= Sleep.meanWakeBoutTime;
        
        ii = ii + 1; % increment independent counter
    end
    
end

% Prepare results for output
OutputDataset = struct2dataset(Output);
idxEmpty = cellfun(@isempty,OutputDataset.actualSleepTimeMins);
OutputDataset(idxEmpty,:) = [];
outputCell = dataset2cell(OutputDataset);
varNameArray = outputCell(1,:);
prettyVarNameArray = lower(regexprep(varNameArray,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNameArray;

% Average results
AveragedOutput = struct(...
    'subject'               , {[]} ,...
    'nightsAveraged'        , {[]} ,...
    'actualSleepTimeMins',    {[]},...
    'actualSleepPercent',     {[]},...
    'actualWakeTimeMins',     {[]},...
    'actualWakePercent',      {[]},...
    'sleepEfficiency',        {[]},...
    'sleepOnsetLatencyMins',  {[]},...
    'sleepBouts',             {[]},...
    'wakeBouts',              {[]},...
    'meanSleepBoutTimeMins',  {[]},...
    'meanWakeBoutTimeMins',   {[]});
unqSubjectArray = unique(OutputDataset.subject);

varnames = fieldnames(Output);
idxSubjectVar = strcmp('subject',varnames);
idxNightVar = strcmp('night',varnames);
idxVarRemove = idxSubjectVar | idxNightVar;
varnames(idxVarRemove) = [];

for j1 = 1:numel(unqSubjectArray)
    AveragedOutput(j1,1).subject = unqSubjectArray(j1);
    idxSubject = OutputDataset.subject == unqSubjectArray(j1);
    AveragedOutput(j1,1).nightsAveraged = numel(OutputDataset.night(idxSubject));
    
    for j2 = 1:numel(varnames)
        AveragedOutput(j1,1).(varnames{j2}) = mean(cell2mat(OutputDataset.(varnames{j2})(idxSubject)));
    end
end

% Prepare results for output
AveragedOutputDataset = struct2dataset(AveragedOutput);
averagedOutputCell = dataset2cell(AveragedOutputDataset);
varNameArray2 = averagedOutputCell(1,:);
prettyVarNameArray2 = lower(regexprep(varNameArray2,'([^A-Z])([A-Z0-9])','$1 $2'));
averagedOutputCell(1,:) = prettyVarNameArray2;

% Save results to an MS Excel file
xlswrite([resultsPath,'.xlsx'],outputCell);
xlswrite([resultsPath,'_averaged.xlsx'],averagedOutputCell);
% % Save results to a Matlab file
% save([resultsPath,'.mat'],'Output');

end