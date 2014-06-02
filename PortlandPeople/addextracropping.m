function logicalArray = addextracropping(CropLog,subject,timeArray,logicalArray)
%ADDEXTRACROPPING Summary of this function goes here
%   Detailed explanation goes here

% Find the row that corresponds to the desired subject
subjectIdx = CropLog.subject == subject;
if ~any(subjectIdx)
    error(['Subject ',num2str(subject),' not found in CropLog.']);
end
CropLog = CropLog(subjectIdx,:);

% Determine what variables that are start and stop
varNames = fieldnames(CropLog);
cleanVarNames = regexprep(varNames,'^(\w*)\d.*','$1');
startIdx = strcmpi('rmStart',cleanVarNames);
stopIdx  = strcmpi('rmStop' ,cleanVarNames);
startVarNames = varNames(startIdx);
stopVarNames  = varNames(stopIdx);

% Determine the minimum number of removal chunks to check for
nChunks = min(numel(startVarNames),numel(stopVarNames));
if nChunks < 1
    error('No removal variables detected. Check variable names.');
end

% Preallocate variables
rmStartTimeArray = zeros(nChunks,1);
rmStopTimeArray  = zeros(nChunks,1);

% Reassign removal start and stop times
for i1 = 1:nChunks
    rmStartTimeArray(i1)  = CropLog.(startVarNames{i1});
    rmStopTimeArray(i1) = CropLog.(stopVarNames{i1});
end

% Remove NaN values
nanIdx = isnan(rmStartTimeArray) | isnan(rmStopTimeArray);
rmStartTimeArray(nanIdx)  = [];
rmStopTimeArray(nanIdx) = [];

% Check if there are any chunks to be removed if not exit the function
% returning the original logicalArray
nChunks = min(numel(rmStartTimeArray),numel(rmStopTimeArray));
if nChunks < 1
    return;
end

for i2 = 1:nChunks
    tempLogicalArray = ~(timeArray >= rmStartTimeArray(i2) & timeArray <= rmStopTimeArray(i2));
    logicalArray = logicalArray & tempLogicalArray;
end


end

