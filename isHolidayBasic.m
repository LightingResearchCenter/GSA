function TF = isHolidayBasic(timeArray)
%ISHOLIDAY Summary of this function goes here
%   Detailed explanation goes here

% List of dates to exclude
% List source: https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/
holidays2014 = datenum([...
            2014,  1,  1;... % New Year’s Day
            2014,  1, 20;... % Birthday of Martin Luther King, Jr.
            2014,  2, 17;... % Washington’s Birthday
            2014,  5, 26;... % Memorial Day
            2014,  7,  4;... % Independence Day
            2014,  9,  1;... % Labor Day
            2014, 10, 13;... % Columbus Day
            2014, 11, 11;... % Veterans Day
            2014, 11, 27;... % Thanksgiving Day
            2014, 12, 25 ... % Christmas Day
            ]);
holidays2015 = datenum([...
            2015,  1,  1;... % New Year’s Day
            2015,  1, 19;... % Birthday of Martin Luther King, Jr.
            2015,  2, 16;... % Washington’s Birthday
            2015,  5, 25;... % Memorial Day
            2015,  7,  3;... % Independence Day
            2015,  9,  7;... % Labor Day
            2015, 10, 12;... % Columbus Day
            2015, 11, 11;... % Veterans Day
            2015, 11, 26;... % Thanksgiving Day
            2015, 12, 25 ... % Christmas Day
            ]);
holidays2016 = datenum([...
            2015,  1,  1;... % New Year’s Day
            2015,  1, 18;... % Birthday of Martin Luther King, Jr.
            2015,  2, 15;... % Washington’s Birthday
            2015,  5, 30;... % Memorial Day
            2015,  7,  4;... % Independence Day
            2015,  9,  5;... % Labor Day
            2015, 10, 10;... % Columbus Day
            2015, 11, 11;... % Veterans Day
            2015, 11, 24;... % Thanksgiving Day
            2015, 12, 26 ... % Christmas Day
            ]);

holidays = [holidays2014;holidays2015;holidays2016];

% Find holidays
nHoliday = numel(holidays);
tempHolidayMask = false(numel(timeArray),nHoliday);
for iHoliday = 1:nHoliday
    thisHoliday = holidays(iHoliday);
    tempHolidayMask(:,iHoliday) = timeArray >= thisHoliday & timeArray < thisHoliday + 1;
end

TF = any(tempHolidayMask,2);

end

