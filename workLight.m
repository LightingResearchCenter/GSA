function [workCS,workLux] = workLight(time,CS,Lux)
%WORKLIGHT Summary of this function goes here
%   Detailed explanation goes here


%% Find work days and remove weekends
[D,~] = weekday(time);
wkIdx = D >= 2 & D <= 6; % Work week of Monday through Friday
% Remove weekends
time(~wkIdx) = [];
CS(~wkIdx) = [];
Lux(~wkIdx) = [];

%% Find time during workday and remove the rest
hour = mod(time,1)*24; % convert datenum to hour of day
hrIdx = hour >= 8 & hour <= 13; % Work day of 8 AM through 5 PM
% Remove outside the work day
CS(~hrIdx) = [];
Lux(~hrIdx) = [];

%% Remove zero values
CS(CS<=0) = [];
Lux(Lux<=0) = [];

%% Average the work day data
workCS = mean(CS);
workLux = 10^mean(log10(Lux));

end

