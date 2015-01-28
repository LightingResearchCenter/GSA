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
    locationID      = Data.GlobalAttributes.subjectID{1};
    deviceSN        = Data.GlobalAttributes.deviceSN{1};
    logicalArray	= logical(Data.Variables.logicalArray);
    
    locationID = [locationID,' D',deviceSN(end-2:end)];
    
    if exist('Data.Variables.complianceArray','var') ~= 0
        complianceArray  = logical(Data.Variables.complianceArray);
    else
        complianceArray = true(size(logicalArray));
    end
    newLogicalArray  = logicalArray & complianceArray;
    timeArray        = Data.Variables.time(newLogicalArray);
    csArray          = Data.Variables.CS(newLogicalArray);
    illuminanceArray = Data.Variables.illuminance(newLogicalArray);
    activityArray    = Data.Variables.activity(newLogicalArray);
    
    % Crop data to work times
    workIdx = createworkday(timeArray,workStart,workEnd);
    timeArray        = timeArray(workIdx);
    timeArrayHrs     = datenum2hour(timeArray);
    csArray          = csArray(workIdx);
    illuminanceArray = illuminanceArray(workIdx);
    activityArray    = activityArray(workIdx);
    
    % Make Miller Plot
    [millerTimeArray_hours,millerCsArray] = millerize(timeArray,csArray);
    [~,millerActivityArray] = millerize(timeArray,activityArray);
    
    millerplot(Paths.plots,locationID,displayLocation,displaySession,...
        millerTimeArray_hours,millerCsArray,millerActivityArray);
    
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

close all

end


function [millerTimeArray_hours,millerDataArray] = millerize(timeArray,dataArray)

relTimeArray_days = mod(timeArray-floor(timeArray(1)),1);

relTimeArray_seconds = round(relTimeArray_days*24*60*60/30)*30; % precise to 30 seconds

millerTimeArray_seconds = unique(relTimeArray_seconds);

nPoints = numel(millerTimeArray_seconds);

millerDataArray = zeros(nPoints,1);

for i1 = 1:nPoints
    idx = relTimeArray_seconds == millerTimeArray_seconds(i1);
    millerDataArray(i1) = mean(dataArray(idx));
end

millerTimeArray_hours = millerTimeArray_seconds/(60*60);

end

function millerplot(plotDir,locationID,displayLocation,displaySession,millerTimeArray_hours,millerCsArray,millerActivityArray)

clf

% Create axes to plot on
hAxes = axes;
hold('on');

set(hAxes,'XTick',0:2:24);
set(hAxes,'TickDir','out');

xlim(hAxes,[0 24]);

yMax = 0.7;
if max(millerActivityArray) > yMax
    yMax = max(mAI);
else
    yTick = 0:0.1:0.7;
    set(hAxes,'YTick',yTick);
end
ylim(hAxes,[0 yMax]);
box('off');

% Plot AI
area1 = area(hAxes,millerTimeArray_hours,millerActivityArray,'LineStyle','none');
set(area1,...
    'FaceColor',[180, 211, 227]/256,'EdgeColor','none',...
    'DisplayName','Activity Index (AI)');

% Plot CS
plot1 = plot(hAxes,millerTimeArray_hours,millerCsArray);
set(plot1,...
    'Color','k','LineWidth',2,...
    'DisplayName','Circadian Stimulus (CS)');

% Create x-axis label
xlabel('Time (hours)');

% Create title
titleStr = {['GSA - ',displayLocation,' - ',displaySession];locationID};
hTitle = title(titleStr);
set(hTitle,'FontSize',16);

% Plot a box
z = [100,100];
hLine1 = line([0 24],[yMax yMax],z,'Color','k');
hLine2 = line([24 24],[0 yMax],z,'Color','k');
hLine3 = line([0 24],[0 0],z,'Color','k');
hLine4 = line([0 0],[0 yMax],z,'Color','k');

set(hLine1,'Clipping','off');
set(hLine2,'Clipping','off');
set(hLine3,'Clipping','off');
set(hLine4,'Clipping','off');

% Create legend
legend1 = legend([area1,plot1]);
set(legend1,'Orientation','horizontal','Location','Best');

fileName = ['millerPlot_',datestr(now,'yyyy-mm-dd_HHMM'),'_locationID',locationID];
filePath = fullfile(plotDir,fileName);
print(gcf,'-dpdf',filePath,'-painters');

end

