function batchhourlyportland
%BATCHHOURLYPORTLAND Summary of this function goes here
%   Detailed explanation goes here

% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_Stick_and_Window_data');
cdfDir = fullfile(projectDir,'editedData');
resultsDir = fullfile(projectDir,'results');

outputExcelPath = fullfile(resultsDir,['hourlyAverage_',datestr(now,'yyyy-mm-dd_HH-MM'),'.xlsx']);
outputMatPath = fullfile(resultsDir,'hourlyAverage.mat');

% Get a listing of all CDF files in the folder
listing = dir([cdfDir,filesep,'*.cdf']);

% Specify dates of sunny days
sunnyDayArray = [datenum(2014,4,30);...
                 datenum(2014,5, 7);...
                 datenum(2014,5,11);...
                 datenum(2014,5,13)];

% Preallocate output
nFile = numel(listing);

emptyCell = cell(nFile,1);
hourlyData = struct(...
    'daysimeter'    , emptyCell ,...
    'location'      , emptyCell ,...
    'time'          , emptyCell ,...
    'hour'          , emptyCell ,...
    'lux'           , emptyCell ,...
    'cla'           , emptyCell ,...
    'cs'            , emptyCell ,...
    'sunnyDay'      , emptyCell  ...
    );

% Begin main loop
for i1 = 1:nFile
    % Load file
    filePath = fullfile(cdfDir,listing(i1).name);
    Data = ProcessCDF(filePath);
    serialNumber = Data.GlobalAttributes.deviceSN{1};
    location = Data.GlobalAttributes.subjectID{1};
    logicalArray = logical(Data.Variables.logicalArray);
    Daysimeter = struct;
    Daysimeter.time = Data.Variables.time(logicalArray);
    Daysimeter.lux = Data.Variables.illuminance(logicalArray);
    Daysimeter.cla = Data.Variables.CLA(logicalArray);
    Daysimeter.cs = Data.Variables.CS(logicalArray);
    
    % Add hour array
    Daysimeter.hour = datenum2hour(Daysimeter.time);
    
    % Chop low end lux and CLA to threshold of 0.005
    threshold = 0.005;
    Daysimeter.lux = choptothreshold(Daysimeter.lux,threshold);
    Daysimeter.cla = choptothreshold(Daysimeter.cla,threshold);
    
    % Average data
    hourlyData(i1) = hourlyaverage(Daysimeter,serialNumber,location,sunnyDayArray);
    
    % Convert data to cell
    dataCell = hourly2cell(hourlyData(i1));
    
    % Add header row
    header = fieldnames(hourlyData(i1))';
    outputCell = [header;dataCell];
    
    % Save output to spreadsheet
    sheet = location;
    xlswrite(outputExcelPath,outputCell,sheet);

end

% Save output to matlab file
save(outputMatPath,'hourlyData');

end


function dataCell = hourly2cell(hourlyStruct)

variableNameArray = fieldnames(hourlyStruct);
nVariables = numel(variableNameArray);

varSizeArray = structfun(@numel,hourlyStruct);
maxVarLength = max(varSizeArray);
paddingNeeded = maxVarLength - varSizeArray;

dataCell = [];

for i1 = 1:nVariables
    tempArray = hourlyStruct.(variableNameArray{i1});
    if strcmpi(variableNameArray{i1},'time')
        % Convert time to text for Excel
        strTime = datestr(tempArray,'mm/dd/yyyy HH:MM');
        cellArray = cellstr(strTime);
    elseif iscell(tempArray)
        cellArray = tempArray;
    else
        cellArray = num2cell(tempArray);
    end
    cellArray = cellArray(:);
    paddingCell = cell(paddingNeeded(i1),1);
    cellArrayPadded = [cellArray;paddingCell];
    dataCell = [dataCell,cellArrayPadded];
end

end


