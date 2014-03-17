function [hrTime,hrLux,hrCLA,hrCS,hrActivity] = hourlyAverage(time,Lux,CLA,CS,activity)
%HOURLYAVERAGE Summary of this function goes here
%   Detailed explanation goes here

% Round time to the next hour
time = ceil(time*24)/24;
hrTime = unique(time);

% Preallocate variables
n = numel(hrTime);
hrLux = zeros(n,1);
hrCLA = zeros(n,1);
hrCS = zeros(n,1);
hrActivity = zeros(n,1);

% Average data for each hour
for i1 = 1:n
    idx = time == hrTime(i1);
    hrLux(i1) = 10^mean(log10(Lux(idx)));
    hrCLA(i1) = 10^mean(log10(CLA(idx)));
    hrCS(i1) = mean(CS(idx));
    hrActivity(i1) = mean(activity(idx));
end

end

