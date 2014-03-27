function dailyStruct = dailyaverage(hourlyStruct)
%DAILYAVERAGE Summary of this function goes here
%   Detailed explanation goes here

dailyStruct = struct;
dailyStruct.daysimeter	= hourlyStruct.daysimeter;
dailyStruct.mountStyle	= hourlyStruct.mountStyle;
dailyStruct.orientation	= hourlyStruct.orientation;


hourArray = (hourlyStruct.time - floor(hourlyStruct.time))*24;
hourArray = round(hourArray);

dailyStruct.hour = (0:23)';

dailyStruct.luxCloudy = zeros(24,1);
dailyStruct.claCloudy = zeros(24,1);
dailyStruct.csCloudy = zeros(24,1);
dailyStruct.activityCloudy = zeros(24,1);

dailyStruct.luxSunny = zeros(24,1);
dailyStruct.claSunny = zeros(24,1);
dailyStruct.csSunny = zeros(24,1);
dailyStruct.activitySunny = zeros(24,1);

for i1 = 1:numel(dailyStruct.hour)
    idxHour = hourArray == dailyStruct.hour(i1);
    idxCloudy = ~hourlyStruct.sunnyDay & idxHour;
    idxSunny = hourlyStruct.sunnyDay & idxHour;
    
    dailyStruct.luxCloudy(i1)       = logaverage(hourlyStruct.lux(idxCloudy));
    dailyStruct.claCloudy(i1)       = logaverage(hourlyStruct.cla(idxCloudy));
    dailyStruct.csCloudy(i1)        = mean(hourlyStruct.cs(idxCloudy));
    dailyStruct.activityCloudy(i1)	= mean(hourlyStruct.activity(idxCloudy));
    
    dailyStruct.luxSunny(i1)       = logaverage(hourlyStruct.lux(idxSunny));
    dailyStruct.claSunny(i1)       = logaverage(hourlyStruct.cla(idxSunny));
    dailyStruct.csSunny(i1)        = mean(hourlyStruct.cs(idxSunny));
    dailyStruct.activitySunny(i1)	= mean(hourlyStruct.activity(idxSunny));
end

end

