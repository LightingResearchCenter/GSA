function cloudysunnyaveragesworkday
%CLOUDYSUNNYAVERAGESWORKDAY Summary of this function goes here
%   Detailed explanation goes here

% File handling
[parentDir,~,~] = fileparts(pwd);
addpath(parentDir);

projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','GSA Daysimeters on a Stick - Seattle Data');
resultsDir = fullfile(projectDir,'results');

inputPath = fullfile(resultsDir,'dailyAverageWorkDay.mat');
outputExcelPath = fullfile(resultsDir,['cloudySunnyAverageWorkDay_',datestr(now,'yyyy-mm-dd_HH-MM'),'.xlsx']);
outputMatPath = fullfile(resultsDir,'cloudySunnyAverageWorkDay.mat');

inputStruct = load(inputPath);
dailyData = inputStruct.dailyData;

% Preallocate variables
nEntries = numel(dailyData);

% find window and stick daysimeters
idxStick = false(nEntries,1);
idxWindow = false(nEntries,1);
for i1 = 1:nEntries
    idxStick(i1)	= strcmpi(dailyData(i1).mountStyle{1},'stick');
    idxWindow(i1)	= strcmpi(dailyData(i1).mountStyle{1},'window');
end

% Separate stick and window data
stickDaily	= dailyData(idxStick);
window	= dailyData(idxWindow);

nStick = numel(stickDaily);
nWindow = numel(window);

% Combine the stick data
varNameArray = fieldnames(stickDaily(1));
template = varNameArray';
template(2,1) = {[]};
combinedStick = struct(template{:});

nVar = numel(varNameArray);
for i2 = 1:nStick
    for i3 = 1:nVar
        combinedStick.(varNameArray{i3}) = [combinedStick.(varNameArray{i3}) ; stickDaily(i2).(varNameArray{i3})];
    end
end

% Average stick data
stick = stickaverage(combinedStick);
stickCell = data2cell(stick);

% Add header row
header1 = fieldnames(stick)';
stickOutputCell = [header1;stickCell];

% Save output to spreadsheet
sheet = 'stick daysimeters';
xlswrite(outputExcelPath,stickOutputCell,sheet);


for i4 = 1:nWindow
    windowCell = data2cell(window(i4));

    % Add header row
    header1 = fieldnames(window(i4))';
    windowOutputCell = [header1;windowCell];

    % Save output to spreadsheet
    sheet = ['window daysimeter ',num2str(window(i4).daysimeter),' ',window(i4).orientation{1}];
    xlswrite(outputExcelPath,windowOutputCell,sheet);
end

end


function dataCell = data2cell(dataStruct)

variableNameArray = fieldnames(dataStruct);
nVariables = numel(variableNameArray);

varSizeArray = structfun(@numel,dataStruct);
maxVarLength = max(varSizeArray);
paddingNeeded = maxVarLength - varSizeArray;

dataCell = [];

for i1 = 1:nVariables
    tempArray = dataStruct.(variableNameArray{i1});
    if iscell(tempArray)
        cellArray = tempArray;
    else
        cellArray = num2cell(tempArray);
    end
    paddingCell = cell(paddingNeeded(i1),1);
    cellArrayPadded = [cellArray;paddingCell];
    dataCell = [dataCell,cellArrayPadded];
end

end



