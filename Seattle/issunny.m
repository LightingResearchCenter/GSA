function sunnyDayLogical = issunny(timeArray,sunnyDayArray)
%ISSUNNY Summary of this function goes here
%   Detailed explanation goes here

% Convert time to days
dayArray = floor(timeArray);

% Preallocate output array
sunnyDayLogical = false(size(dayArray));

% Find matching dates (true = match)
for i1 = 1:numel(sunnyDayArray)
    sunnyDayLogical = sunnyDayLogical | (dayArray == sunnyDayArray);
end

end

