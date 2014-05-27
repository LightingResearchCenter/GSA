function fix139
%FIX139 WARNING this function was not able to fix the data
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
DaysigramToolkit = fullfile(parentParentDir,'DaysigramReport');
addpath(CDFtoolkitDir,DaysigramToolkit);

% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_Stick_and_Window_data');
oldDir = fullfile(projectDir,'problemUnit139_12-East-Window');
newDir = fullfile(projectDir,'editedData');
printDir = fullfile(projectDir,'daysigrams');

cdfPath = fullfile(oldDir,'0139-2014-05-22-12-21-01.cdf');

[~,cdfName,cdfExt] = fileparts(cdfPath);
newName = [cdfName,'_edited',cdfExt];
newPath = fullfile(oldDir,newName);

% Load the data
DaysimeterData = ProcessCDF(cdfPath);

% Fix the time
figure('Units','normal','Position',[1,0,1,1]);
plot(DaysimeterData.Variables.time,DaysimeterData.Variables.CS);
datetick2;
zoom('on');
pause;
[dayStart,~] = ginput(1);
zoom('out');
zoom('on');
pause;
[dayEnd,~] = ginput(1);
dayIdx = DaysimeterData.Variables.time >= dayStart & DaysimeterData.Variables.time <= dayEnd;
epochDays = 1/sum(dayIdx);
close(gcf);

% epochDays = 0.002102855867875; % ~181.6867 seconds

correctionArray = (0:numel(DaysimeterData.Variables.time)-1)'*epochDays;
newTimeArray = DaysimeterData.Variables.time(1) + correctionArray;
DaysimeterData.Variables.time = newTimeArray;

% Fix the time sone
% Portland, Oregon: PDT = UTC/GMT -7 hours = -25200 seconds
DaysimeterData.Variables.timeOffset = -7*60*60;

% Crop the data
DaysimeterData = cropCDF(DaysimeterData);

% Save new file
RewriteCDF(DaysimeterData, newPath);

% Plot the data
logicalArray = logical(DaysimeterData.Variables.logicalArray);
timeArray = DaysimeterData.Variables.time(logicalArray);
activityArray = DaysimeterData.Variables.activity(logicalArray);
csArray = DaysimeterData.Variables.CS(logicalArray);
locationID = DaysimeterData.GlobalAttributes.subjectID{1};

sheetTitle = ['GSA (Portland, Oregon) ',locationID];
fileID = locationID;

% Generate the Daysigram
generatereport(sheetTitle,timeArray,activityArray,csArray,...
    'cs',[0,1],11,oldDir,fileID);

end

function DaysimeterData = cropCDF(DaysimeterData)
hCrop = figure('Units','normal','Position',[1,0,1,1]);

subjectID = DaysimeterData.GlobalAttributes.subjectID{1};
timeArray = DaysimeterData.Variables.time;
csArray = DaysimeterData.Variables.CS;
activityArray = DaysimeterData.Variables.activity;

% Provide GUI for cropping of the data
logicalArray = true(size(timeArray));
needsCropping = true;
while needsCropping
    logicalArray = true(size(timeArray));
    plotcrop(hCrop,timeArray,csArray,activityArray,logicalArray)
    plotcroptitle(subjectID,'Select Start of Data');
    zoom(hCrop,'on');
    pause
    [cropStart,~] = ginput(1);
    zoom(hCrop,'out');
    zoom(hCrop,'on');
    plotcroptitle(subjectID,'Select End of Data');
    pause
    [cropStop,~] = ginput(1);
    logicalArray = (timeArray >= cropStart) & (timeArray <= cropStop);
    plotcrop(hCrop,timeArray,csArray,activityArray,logicalArray)
    plotcroptitle(subjectID,'');
    needsCropping = cropdialog;
end
set(hCrop,'Visible','off');

% Assign the modified variables
DaysimeterData.Variables.logicalArray = logicalArray;

close(hCrop);

end

function needsCropping = cropdialog
button = questdlg('Is this data cropped correctly?','Crop Data','Yes','No','No');
switch button
    case 'Yes'
        needsCropping = false;
    case 'No'
        needsCropping = true;
    otherwise
        needsCropping = false;
end
end

function plotcrop(hCrop,timeArray,csArray,activityArray,logicalArray2)
figure(hCrop)
clf(hCrop)
plot(timeArray(logicalArray2),[csArray(logicalArray2),activityArray(logicalArray2)])
datetick2('x');
legend('Circadian Stimulus','Activity');

end

function plotcroptitle(subjectName,subTitle)

hTitle = title({subjectName;subTitle});
set(hTitle,'FontSize',16);
    
end