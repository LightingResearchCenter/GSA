function logicalArray = adjustcrop(timeArray,logicalArray)
%ADJUSTCROP Summary of this function goes here
%   Detailed explanation goes here

% Find blocks marked to be removed
D = diff(double(logicalArray));

cropStartArray = find(D == -1);
cropStartArray = cropStartArray + 1;
cropStopArray  = find(D ==  1);

% Ignore cropping at ends of data
if ~logicalArray(1)
    cropStopArray(1) = [];
end

if ~logicalArray(end)
    cropStartArray(end) = [];
end

nStarts = numel(cropStartArray);
nStops  = numel(cropStopArray);

if nStarts ~= nStops
    error('Missmatched number of crop starts and stops');
end

if nStarts < 1
    return;
end

for i1 = 1:nStarts
    startTime = timeArray(cropStartArray(i1));
    stopTime  = timeArray(cropStopArray(i1));
    durationDays = stopTime - startTime;
    durationHrs  = durationDays*24; % duration in hours
    
    % ignore blocks less than 3 hours
    if durationHrs < 3
        logicalArray(cropStartArray(i1):cropStopArray(i1)) = true;
        continue;
    end
    
    % expand the block to a multiple of 24 hours
    modDuration = mod(durationDays,1);
    paddingTimeDays = (1-modDuration)/2;
    newStartTime = startTime - paddingTimeDays;
    newStopTime  = stopTime  + paddingTimeDays;
    newCropBlock = ~(timeArray >= newStartTime & timeArray <= newStopTime);
    
    % combine new crop block with existing logical array
    logicalArray = logicalArray & newCropBlock;
    
end


end

