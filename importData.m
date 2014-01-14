function [PIM,dTime,CS,AI] = importData(daysimPath,daysimSN)
%IMPORTDATA Import data from Actiwatch and Daysimeter files
%   Detailed description goes here

%% Check if files exist
% Check if Daysimeter file exists
if exist(daysimPath,'file') ~= 2
    error(['Daysimeter file does not exist. File: ',daysimPath]);
end

%% Load Daysimeter file
% Create CDF file name
CDFdaysimPath = regexprep(daysimPath,'\.txt','.cdf');
% Check if CDF versions exist
if exist(CDFdaysimPath,'file') == 2 % CDF Daysimeter file exists
    daysimData = ProcessCDF(CDFdaysimPath);
    dTime = daysimData.Variables.Time;
    CS = daysimData.Variables.CS;
    AI = daysimData.Variables.Activity;
else % CDF Actiwatch file does not exist
    % Reads the data from the dimesimeter data file
    [dTime,lux,CLA,CS,AI] = importDime(daysimPath,daysimSN);
    % Create a CDF version
    WriteDaysimeterCDF(CDFdaysimPath,dTime,lux,CLA,CS,AI);
end

end

