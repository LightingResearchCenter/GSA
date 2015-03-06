function averagedata
%AVERAGEDATA Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
[github,~,~] = fileparts(pwd);
circadian = fullfile(github,'circadian');
addpath(circadian);

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[cdfNameArray,cdfPathArray] = searchdir(Paths.editedData,'cdf');
weatherLogPath = fullfile(Paths.logs,'weatherLog.xlsx');

runtime = datestr(now,'yyyy-mm-dd_HHMM');
desktop = 'C:\Users\jonesg5\Desktop\forClaudia';
resultsPath = fullfile(desktop,['hourlyAverage_',runtime,'_GSA_',plainLocation,'_',plainSession,'.xlsx']);


sunnyDayArray = importweatherlog(weatherLogPath);
workStart = 8;
workEnd   = 17;
hourArray = (workStart+1:workEnd)';

nFile = numel(cdfPathArray);
nHour = numel(hourArray);
template = cell(nHour+2,nFile+1);

template{1,1} = 'DeviceSN';
template{2,1} = 'LocationID';

for iHour = 1:nHour
    thisHour = hourArray(iHour);
    
    hourLabel = sprintf('%d:00 - %d:00',thisHour-1,thisHour);
    template{iHour+2,1} = hourLabel;
end

Results = struct;
Results.allLuxGeoMean    = template;
Results.allCsAriMean     = template;
Results.sunnyLuxGeoMean  = template;
Results.sunnyCsAriMean   = template;
Results.cloudyLuxGeoMean = template;
Results.cloudyCsAriMean  = template;

varNames = fieldnames(Results);
nVar = numel(varNames);

for iFile = 1:nFile
    % Import data
    cdfData = daysimeter12.readcdf(cdfPathArray{iFile});
    [absTime,relTime,epoch,light,activity,masks,locationID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
    
    % Skip windows
    if ~isempty(regexpi(locationID,'window'))
        continue
    end
    
    logicalArray = masks.observation;
    
    if exist('masks.compliance','var') ~= 0
        complianceArray  = masks.compliance;
    else
        complianceArray = true(size(logicalArray));
    end
    newLogicalArray  = logicalArray & complianceArray;
    timeArray        = absTime.localDateNum(newLogicalArray);
    csArray          = light.cs(newLogicalArray);
    illuminanceArray = light.illuminance(newLogicalArray);
    
    % Set deviceSN and locationID
    for iVar = 1:nVar
        thisVar = varNames{iVar};
        Results.(thisVar){1,iFile+1} = deviceSN;
        Results.(thisVar){2,iFile+1} = locationID;
    end
    
    
    % Crop DC December 2014
    if strcmpi(plainLocation,'dc') && strcmpi(plainSession,'december')
        keepIdx = timeArray > datenum(2014,12,4) & timeArray < datenum(2014,12,20);
        timeArray        = timeArray(keepIdx);
        csArray          = csArray(keepIdx);
        illuminanceArray = illuminanceArray(keepIdx);
    end
    
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
    
    for iHour = 1:nHour
        thisHour = hourArray(iHour);
        thisHourIdx = timeArrayHrs == thisHour;
        % Overall averages
        Results.allLuxGeoMean{iHour+2,iFile+1} = geomean(illuminanceArray(thisHourIdx));
        Results.allCsAriMean{iHour+2,iFile+1}  = mean(csArray(thisHourIdx));
        % Sunny averages
        currentSunny = sunnyDayLogical & thisHourIdx;
        Results.sunnyLuxGeoMean{iHour+2,iFile+1} = geomean(illuminanceArray(currentSunny));
        Results.sunnyCsAriMean{iHour+2,iFile+1}  = mean(csArray(currentSunny));
        % Cloudy averages
        currentCloudy = ~sunnyDayLogical & thisHourIdx;
        Results.cloudyLuxGeoMean{iHour+2,iFile+1} = geomean(illuminanceArray(currentCloudy));
        Results.cloudyCsAriMean{iHour+2,iFile+1}  = mean(csArray(currentCloudy));
    end
        
    
end

% Save Results to spreadsheet
for iVar = 1:nVar
    thisVar = varNames{iVar};
    thisResult = Results.(thisVar);
    
    % Remove empty rows
    emptyCellIdx = cellfun(@isempty,thisResult);
    emptyRowIdx = emptyCellIdx(1,:);
    thisResult(:,emptyRowIdx) = [];
    
    xlswrite(resultsPath,thisResult,thisVar);
    
end

end

