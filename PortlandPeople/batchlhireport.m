function batchlhireport
% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
LHIToolkit = fullfile(parentParentDir,'LHIReport');
PhasorToolkit = fullfile(parentParentDir,'PhasorAnalysis');
addpath(CDFtoolkitDir,LHIToolkit,PhasorToolkit);

% Specify directories
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_People_Data');

cdfDir = fullfile(projectDir,'summerEditedData');

printDir = fullfile(projectDir,'summerReports');

bedLogPath = fullfile(projectDir,'summerBedLog.xlsx');

% Import the bed log
BedLog = importbedlog(bedLogPath);

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Create Reports
% Preallocate variables
% Prepare the figures
visible = 'on';
figTitle = 'GSA - Portland, OR (Summer 2014)';
[hFigure,~,~,units] = initializefigure(visible);
for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    logicalArray = logical(DaysimeterData.Variables.logicalArray);
    timeArray = DaysimeterData.Variables.time;
    
    % Adjust cropping
    logicalArray = adjustcrop(timeArray,logicalArray);
    
    timeArray = DaysimeterData.Variables.time(logicalArray);
    activityArray = DaysimeterData.Variables.activity(logicalArray);
    csArray = DaysimeterData.Variables.CS(logicalArray);
    illuminanceArray = DaysimeterData.Variables.illuminance(logicalArray);
    subject = DaysimeterData.GlobalAttributes.subjectID{1};
    subjectNum = str2double(subject);
    
    % Skip files with not enough useable data
    if numel(timeArray) < 24
        warning([listing(i1).name,' skipped due to insufficient data.']);
        continue;
    end
    
    % Select the corresponding bed log
    try
        [bedTimeArray,riseTimeArray] = selectbedlog(BedLog,subjectNum);
    catch err
        warning(err.message);
        continue;
    end
    
    % Replace data during bed time with zero values
    [csArray,illuminanceArray,activityArray] = ...
        replacebed(timeArray,csArray,illuminanceArray,activityArray,...
        bedTimeArray,riseTimeArray);
    
    try
        generatereport(printDir,timeArray,csArray,activityArray,illuminanceArray,subject,hFigure,units,figTitle);
    catch err
        warning(err.message);
    end
    % Clear figures
    clf(hFigure);
end

close(hFigure);

end