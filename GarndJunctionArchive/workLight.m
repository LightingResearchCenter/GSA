function [workCS,workLux] = workLight(time,CS,Lux)
%WORKLIGHT Summary of this function goes here
%   Detailed explanation goes here


% Find work days
[D,~] = weekday(time);
wkIdx = D >= 2 & D <= 6; % Work week of Monday through Friday

% Find time during workday and remove the rest
hour = mod(time,1)*24; % convert datenum to hour of day
hrIdx = hour >= 8 & hour < 17; % Work day of 8 AM through 5 PM

% Find non-zero values
csNzIdx = CS>0;
lxNzIdx = Lux>0;

% Find indicies of data to average
csIdx = wkIdx & hrIdx & csNzIdx;
lxIdx = wkIdx & hrIdx & lxNzIdx;

% Average the work day data
workCS = mean(CS(csIdx));
workLux = 10^mean(log10(Lux(lxIdx)));

end

