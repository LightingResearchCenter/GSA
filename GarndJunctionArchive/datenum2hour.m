function hourArray = datenum2hour(timeArray)
%DATENUM2HOUR Summary of this function goes here
%   Detailed explanation goes here

% Rounds up so that averages will be for the hour previous
hourArray = ceil((timeArray - floor(timeArray))*24);

end

