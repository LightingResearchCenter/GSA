function dailyStruct = dailyaveragealldays(hourlyStruct)
%DAILYAVERAGEALLDAYS Summary of this function goes here
%   Detailed explanation goes here

dailyStruct = struct;
dailyStruct.daysimeter	= hourlyStruct.daysimeter;
dailyStruct.mountStyle	= hourlyStruct.mountStyle;
dailyStruct.orientation	= hourlyStruct.orientation;

hourArray = round((hourlyStruct.time - floor(hourlyStruct.time))*24);

dailyStruct.hour = sort(unique(hourArray));

nHours = numel(dailyStruct.hour);

dailyStruct.lux = zeros(nHours,1);
dailyStruct.cla = zeros(nHours,1);
dailyStruct.cs = zeros(nHours,1);
dailyStruct.activity = zeros(nHours,1);

for i1 = 1:numel(dailyStruct.hour)
    idxHour = hourArray == dailyStruct.hour(i1);
    
    dailyStruct.lux(i1)       = logaverage(hourlyStruct.lux(idxHour));
    dailyStruct.cla(i1)       = logaverage(hourlyStruct.cla(idxHour));
    dailyStruct.cs(i1)        = mean(hourlyStruct.cs(idxHour));
    dailyStruct.activity(i1)	= mean(hourlyStruct.activity(idxHour));
end

end

