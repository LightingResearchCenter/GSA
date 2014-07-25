function averagedata
%AVERAGEDATA Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[cdfNameArray,cdfPathArray] = searchdir(Paths.editedData,'cdf');
weatherLogPath = fullfile(Paths.logs,'weatherLog.xlsx');

runtime = datestr(now,'yyyy-mm-dd_HHMM');
resultsPath = fullfile(Paths.results,['hourlyAverage_',runtime,'_GSA_',plainLocation,'_',plainSession,'.xlsx']);


sunnyDayArray = importweatherlog(weatherLogPath);
workStart = 8;
workEnd   = 17;
hourArray = (workStart+1:workEnd)';
labels = {'hour','all lux','all cs','sunny lux','sunny cs','cloudy lux','cloudy cs'};
template = zeros(size(hourArray));
allLux = template;
allCs = template;
sunnyLux = template;
sunnyCs = template;
cloudyLux = template;
cloudyCs = template;

nFiles = numel(cdfPathArray);
for i1 = 1:nFiles
    % Import data
    Data = ProcessCDF(cdfPathArray{i1});
    locationID       = Data.GlobalAttributes.subjectID{1};
    logicalArray     = logical(Data.Variables.logicalArray);
    timeArray        = Data.Variables.time(logicalArray);
    csArray          = Data.Variables.CS(logicalArray);
    illuminanceArray = Data.Variables.illuminance(logicalArray);
    
    % Crop data to work times
    workIdx = createworkday(timeArray,workStart,workEnd);
    timeArray        = timeArray(workIdx);
    timeArrayHrs     = datenum2hour(timeArray);
    csArray          = csArray(workIdx);
    illuminanceArray = illuminanceArray(workIdx);
    
    % Round data to threshold
    csArray = choptothreshold(csArray,0.005);
    illuminanceArray = choptothreshold(illuminanceArray,0.005);
    
    % Identify sunny times
    sunnyDayLogical = issunny(timeArray,sunnyDayArray);
    
    for i2 = 1:numel(hourArray)
        currentHour = timeArrayHrs == hourArray(i2);
        % Overall averages
        allLux(i2) = logaverage(illuminanceArray(currentHour));
        allCs(i2)  = mean(csArray(currentHour));
        % Sunny averages
        currentSunny = sunnyDayLogical & currentHour;
        sunnyLux(i2) = logaverage(illuminanceArray(currentSunny));
        sunnyCs(i2)  = mean(csArray(currentSunny));
        % Cloudy averages
        currentCloudy = ~sunnyDayLogical & currentHour;
        cloudyLux(i2) = logaverage(illuminanceArray(currentCloudy));
        cloudyCs(i2)  = mean(csArray(currentCloudy));
    end
    
    dataMat = [hourArray,allLux,allCs,sunnyLux,sunnyCs,cloudyLux,cloudyCs];
    dataCell = [labels;num2cell(dataMat)];
    
    % Save output to spreadsheet
    sheet = locationID;
    xlswrite(resultsPath,dataCell,sheet);
end

end

