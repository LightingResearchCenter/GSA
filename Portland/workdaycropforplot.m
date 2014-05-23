function data = workdaycropforplot(data)
%WORKDAYCROPFORPLOT Summary of this function goes here
%   Detailed explanation goes here

dayOfWeekArray = weekday(data.time);
workWeekStart	= 2; % Monday
workWeekEnd     = 6; % Friday
idxWorkWeek = (dayOfWeekArray >= workWeekStart) & (dayOfWeekArray <= workWeekEnd);

workDayStart = 8;	% 8 AM
workDayEnd   = 17;	% 5 PM
idxWorkDay = (data.hour > workDayStart) & (data.hour <= workDayEnd);


idxToZero = ~(idxWorkWeek & idxWorkDay);

variableNameArray = fieldnames(data);
n = numel(variableNameArray);

for i1 = 1:n
    temp = data.(variableNameArray{i1});
    if numel(temp) == 1 % Skip struct elements that are not time series
        continue;
    elseif any(strcmpi(variableNameArray{i1},{'time','hour'}))
        continue;
    elseif any(strcmpi(variableNameArray{i1},{'lux','cla'}))
        temp(idxToZero,:) = 0.005;
    else
        temp(idxToZero,:) = 0;
    end
    data.(variableNameArray{i1}) = temp;
end


end

