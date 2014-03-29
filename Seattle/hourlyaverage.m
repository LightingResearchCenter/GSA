function hourlyStruct = hourlyaverage(daysimeterStruct,daysimeterSN,mountStyle,orientation,sunnyDayArray)
%HOURLYAVERAGE Summary of this function goes here
%   Detailed explanation goes here

% Create new struct
hourlyStruct = struct;

% Reassign variables from index
hourlyStruct.daysimeter = daysimeterSN;
hourlyStruct.mountStyle = mountStyle;
hourlyStruct.orientation = orientation;

dayHourArray = floor(daysimeterStruct.time) + daysimeterStruct.hour/24;

varsToSkip = {'time','daysimeter','mountStyle','orientation','hour'};

varNameArray = fieldnames(daysimeterStruct);
nVar = numel(varNameArray);

% Assign new time
[hourlyStruct.time,ia,~] = unique(dayHourArray);
hourlyStruct.hour = daysimeterStruct.hour(ia,:);

varsToLogAverage = {'lux','cla'};

for i2 = 1:numel(hourlyStruct.time)
    for i3 = 1:nVar
        tempArray = daysimeterStruct.(varNameArray{i3});
        if any(strcmpi(varNameArray{i3},varsToSkip))
            continue;
        else
            idxHour = dayHourArray == hourlyStruct.time(i2);
            if any(strcmpi(varNameArray{i3},varsToLogAverage))
                hourlyStruct.(varNameArray{i3})(i2,1) = logaverage(tempArray(idxHour));
            else
                hourlyStruct.(varNameArray{i3})(i2,1) = mean(tempArray(idxHour));
            end
        end
    end
end

% Find sunny days
hourlyStruct.sunnyDay = issunny(hourlyStruct.time,sunnyDayArray);

end

