function [phasorMagnitude, phasorAngle, IS, IV, mCS, MagH, f24abs] = phasorAnalysis(time, CS, activity)
%PHASORANALYSIS Performs analysis on CS and activity

%% Process and analyze data
epoch = round((time(2)-time(1))*(24*3600)*1000)/1000; % sample epoch in seconds
Srate = 1/epoch; % sample rate in Hertz
% Calculate inter daily stability and variablity
[IS,IV] = IS_IVcalc(activity,1/Srate);

% Apply gaussian filter to data
win = floor(300/epoch); % number of samples in 5 minutes
CS = gaussian(CS, win);
activity = gaussian(activity, win);

% Calculate phasors
[phasorMagnitude, phasorAngle] = cos24(CS, activity, time);
[f24H,f24] = phasor24Harmonics(CS,activity,Srate); % f24H returns all the harmonics of the 24-hour rhythm (as complex numbers)
MagH = sqrt(sum((abs(f24H).^2))); % the magnitude including all the harmonics

mCS = mean(CS);
f24abs = abs(f24);

end
