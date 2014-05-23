function batchhourlyportland
%BATCHHOURLYPORTLAND Summary of this function goes here
%   Detailed explanation goes here

% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','GSA Daysimeters on a Stick - Portland Data');
indexPath = fullfile(projectDir,'index.xlsx');
fileDir = fullfile(projectDir,'Original and Corrected Files');
resultsDir = fullfile(projectDir,'results');

outputExcelPath = fullfile(resultsDir,['hourlyAverage_',datestr(now,'yyyy-mm-dd_HH-MM'),'.xlsx']);
outputMatPath = fullfile(resultsDir,'hourlyAverage.mat');

% Import the index
index = importindex(indexPath);

% Get a listing of all CDF files in the folder
filePathArray = fullfile(fileDir,index.fileName);

% Specify dates of sunny days
sunnyDayArray = datenum(2014,2,27);

% Preallocate output
nFile = numel(filePathArray);

emptyCell = cell(nFile,1);
hourlyData = struct(...
    'daysimeter'    , emptyCell ,...
    'mountStyle'    , emptyCell ,...
    'orientation'	, emptyCell ,...
    'time'          , emptyCell ,...
    'hour'          , emptyCell ,...
    'lux'           , emptyCell ,...
    'cla'           , emptyCell ,...
    'cs'            , emptyCell ,...
    'activity'      , emptyCell ,...
    'sunnyDay'      , emptyCell  ...
    );

% Begin main loop
for i1 = 1:nFile
    % Load file
    daysimeter = importprocesseddaysimeter(filePathArray{i1});
    
    % Add hour array
    daysimeter.hour = datenum2hour(daysimeter.time);
    
    % Crop file
    daysimeter = trimdata(daysimeter,index.startTime(i1),index.stopTime(i1));
    
    % Chop low end lux and CLA to threshold of 0.005
    threshold = 0.005;
    daysimeter.lux = choptothreshold(daysimeter.lux,threshold);
    daysimeter.cla = choptothreshold(daysimeter.cla,threshold);
    
    % Average data
    hourlyData(i1) = hourlyaverage(daysimeter,index.daysimeter(i1),index.mountStyle(i1),index.orientation(i1),sunnyDayArray);
    
    % Convert data to cell
    dataCell = hourly2cell(hourlyData(i1));
    
    % Add header row
    header = fieldnames(hourlyData(i1))';
    outputCell = [header;dataCell];
    
    % Save output to spreadsheet
    sheet = ['daysimeter ',num2str(index.daysimeter(i1))];
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
    paddingCell = cell(paddingNeeded(i1),1);
    cellArrayPadded = [cellArray;paddingCell];
    dataCell = [dataCell,cellArrayPadded];
end

end


