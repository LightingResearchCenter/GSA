function workIdx = createworkday(timeArray,varargin)
%CREATEWORKDAY Summary of this function goes here
%   Detailed explanation goes here

timeArray = timeArray(:);

if nargin == 3
    workStart = varargin{1};
    workEnd   = varargin{2};
else % Default case
    workStart = 8;  % 8 AM
    workEnd   = 17; % 5 PM
end

dayOfWeekArray = weekday(timeArray); % Sunday = 1, Monday = 2, etc.
workDaysIdx    = dayOfWeekArray >= 2 & dayOfWeekArray <= 6;

hourArray = mod(timeArray,1)*24;
workHoursIdx = hourArray > workStart & hourArray <= workEnd;

workIdx = workDaysIdx & workHoursIdx;

end

