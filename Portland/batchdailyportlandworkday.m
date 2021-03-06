function batchdailyportlandworkday
%BATCHDAILYPORTLANDWORKDAY Summary of this function goes here
%   Detailed explanation goes here

% File handling
[parentDir,~,~] = fileparts(pwd);
addpath(parentDir);

projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_Stick_and_Window_data');
resultsDir = fullfile(projectDir,'results');

inputPath = fullfile(resultsDir,'hourlyAverageWorkDay.mat');
outputExcelPath = fullfile(resultsDir,['dailyAverageWorkDay_',datestr(now,'yyyy-mm-dd_HH-MM'),'.xlsx']);
outputMatPath = fullfile(resultsDir,'dailyAverageWorkDay.mat');

inputStruct = load(inputPath);
hourlyData = inputStruct.hourlyData;

% Preallocate variables
nEntries = numel(hourlyData);

% dailyData = struct;

for i1 = 1:nEntries
    dailyData(i1,1) = dailyaverage(hourlyData(i1));
    
    % Convert data to cell
    dataCell = daily2cell(dailyData(i1));
    
    % Add header row
    header = fieldnames(dailyData(i1))';
    outputCell = [header;dataCell];
    
    % Save output to spreadsheet
    sheet = dailyData(i1).location{1};
    xlswrite(outputExcelPath,outputCell,sheet);
end

save(outputMatPath,'dailyData');

end


function dataCell = daily2cell(dailyStruct)

variableNameArray = fieldnames(dailyStruct);
nVariables = numel(variableNameArray);

varSizeArray = structfun(@numel,dailyStruct);
maxVarLength = max(varSizeArray);
paddingNeeded = maxVarLength - varSizeArray;

dataCell = [];

for i1 = 1:nVariables
    tempArray = dailyStruct.(variableNameArray{i1});
    if iscell(tempArray)
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

