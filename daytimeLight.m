function [dayIdx,daytimeCS,daytimeLux] = daytimeLight(timeD,CS,Lux,lat,lon,GMToff)
%DAYTIMECS Calculates mean CS during daylight that is nonzero
%   Inputs:
%       timeD	= time in datenum format
%       CS      = circadian stimulus
%       lat     = latitude, scalar
%       lon     = longitude, scalar
%       GMToff	= offset from GMT to timezone used

%% Calculate sunrise and sunset times
% Find the dates that are included in the data
Date = unique(floor(timeD));
Date = Date(:); % make sure Date is a vertical vector

% Caluclate approximate sunrise and sunset time
[sunrise,sunset] = simpleSunCycle(lat,lon,Date);

% Adjust sunrise and sunset times from GMT to desired timezone
sunrise = sunrise + GMToff/24 + isDST(Date)/24;
sunset = sunset + GMToff/24 + isDST(Date)/24;
% Fix rollover error
idxRoll = sunset < sunrise;
sunset(idxRoll) = sunset(idxRoll) + 1;

%% Find times that occur during the day
% Preallocate the logical index
dayIdx = false(size(timeD));
% Add indexes for daytime of each day
for i1 = 1:numel(Date)
    dayIdx = dayIdx | (timeD >= sunrise(i1) & timeD <= sunset(i1));
end

%% Find the mean daytime light
% Find light during the day
dayCS = CS(dayIdx);
dayLux = Lux(dayIdx);
% Take the average
daytimeCS = mean(dayCS(dayCS > 0));
daytimeLux = 10^mean(log10(dayLux(dayLux > 0)));
end

