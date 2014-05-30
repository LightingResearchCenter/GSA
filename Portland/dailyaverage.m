function dailyStruct = dailyaverage(hourlyStruct)
%DAILYAVERAGE Summary of this function goes here
%   Detailed explanation goes here

dailyStruct = struct;
dailyStruct.daysimeter	= hourlyStruct.daysimeter;
dailyStruct.location	= hourlyStruct.location;

hourArray = round((hourlyStruct.time - floor(hourlyStruct.time))*24);

dailyStruct.hour = sort(unique(hourArray));

nHours = numel(dailyStruct.hour);

dailyStruct.luxAll = zeros(nHours,1);
dailyStruct.claAll = zeros(nHours,1);
dailyStruct.csAll = zeros(nHours,1);

dailyStruct.luxCloudy = zeros(nHours,1);
dailyStruct.claCloudy = zeros(nHours,1);
dailyStruct.csCloudy = zeros(nHours,1);

dailyStruct.luxSunny = zeros(nHours,1);
dailyStruct.claSunny = zeros(nHours,1);
dailyStruct.csSunny = zeros(nHours,1);

for i1 = 1:numel(dailyStruct.hour)
    idxHour = hourArray == dailyStruct.hour(i1);
    idxCloudy = ~hourlyStruct.sunnyDay & idxHour;
    idxSunny = hourlyStruct.sunnyDay & idxHour;
    
    dailyStruct.luxAll(i1)       = logaverage(hourlyStruct.lux(idxHour));
    dailyStruct.claAll(i1)       = logaverage(hourlyStruct.cla(idxHour));
    dailyStruct.csAll(i1)        = mean(hourlyStruct.cs(idxHour));
    
    dailyStruct.luxCloudy(i1)       = logaverage(hourlyStruct.lux(idxCloudy));
    dailyStruct.claCloudy(i1)       = logaverage(hourlyStruct.cla(idxCloudy));
    dailyStruct.csCloudy(i1)        = mean(hourlyStruct.cs(idxCloudy));
    
    dailyStruct.luxSunny(i1)       = logaverage(hourlyStruct.lux(idxSunny));
    dailyStruct.claSunny(i1)       = logaverage(hourlyStruct.cla(idxSunny));
    dailyStruct.csSunny(i1)        = mean(hourlyStruct.cs(idxSunny));
end

end

