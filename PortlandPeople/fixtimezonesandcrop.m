function fixtimezonesandcrop
% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
addpath(CDFtoolkitDir);

% Specify directories
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_People_Data');

oldDir = fullfile(projectDir,'originalData');

newDir = fullfile(projectDir,'editedData');

% Find CDFs in folder
listing = dir([oldDir,filesep,'*.cdf']);
nCdf = numel(listing);

hCrop = figure('Units','normal','Position',[1,0,1,1]);

for i1 = 1:nCdf
    cdfPath = fullfile(oldDir,listing(i1).name);
    [~,cdfName,cdfExt] = fileparts(cdfPath);
    newName = [cdfName,'_edited',cdfExt];
    newPath = fullfile(newDir,newName);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
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
    % Portland, Oregon: PDT = UTC/GMT -7 hours = -25200 seconds
    DaysimeterData.Variables.timeOffset = -7*60*60;
    % Save new file
    RewriteCDF(DaysimeterData, newPath);
    
end

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