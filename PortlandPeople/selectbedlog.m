function [bedTimeArray,riseTimeArray] = selectbedlog(BedLog,subject)
%SELECTBEDLOG Summary of this function goes here
%   Detailed explanation goes here

% Find the row that corresponds to the desired subject
subjectIdx = BedLog.subject == subject;
if ~any(subjectIdx)
    error(['Subject ',num2str(subject),' not found in BedLog.']);
end
BedLog = BedLog(subjectIdx,:);

% Determine what variables are bed times and rise times
varNames = fieldnames(BedLog);
cleanVarNames = regexprep(varNames,'^(\w*)\d.*','$1');
bedIdx  = strcmpi('bedTime' ,cleanVarNames);
riseIdx = strcmpi('riseTime',cleanVarNames);
bedVarNames  = varNames(bedIdx);
riseVarNames = varNames(riseIdx);

% Determine the minimum number of nights that have bed times and rise times
nNights = min(numel(bedVarNames),numel(riseVarNames));
if nNights < 1
    error('No bed or rise times detected. Check variable names.');
end

% Preallocate output variables
bedTimeArray  = zeros(nNights,1);
riseTimeArray = zeros(nNights,1);

% Reassign bed and rise times
for i1 = 1:nNights
    bedTimeArray(i1)  = BedLog.(bedVarNames{i1});
    riseTimeArray(i1) = BedLog.(riseVarNames{i1});
end

% Remove NaN values
nanIdx = isnan(bedTimeArray) | isnan(riseTimeArray);
bedTimeArray(nanIdx)  = [];
riseTimeArray(nanIdx) = [];

% Check if there are any bed or rise times left
if numel(bedTimeArray) < 1 || numel(riseTimeArray) < 1
    error('Not enough bed or rise times were found.');
end


end

