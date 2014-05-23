function batchplotportlandworkday
%BATCHPLOTPORTLANDWORKDAY Summary of this function goes here
%   Detailed explanation goes here

% File handling
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_Stick_and_Window_data');
indexPath = fullfile(projectDir,'index.xlsx');
fileDir = fullfile(projectDir,'Original and Corrected Files');
plotDir = fullfile(projectDir,'plots');

% Import the index
index = importindex(indexPath);

% Get a listing of all CDF files in the folder
filePathArray = fullfile(fileDir,index.fileName);

% Preallocate output
nFile = numel(filePathArray);

% Initialize the figure window
initializefigure;

% Begin main loop
for i1 = 1:nFile
    % Load file
    daysimeter = importprocesseddaysimeter(filePathArray{i1});
    
    % Add hour array
    daysimeter.hour = datenum2hour(daysimeter.time);
    
    % Crop file
    daysimeter = trimdata(daysimeter,index.startTime(i1),index.stopTime(i1));
    daysimeter = workdaycropforplot(daysimeter);
    
    % Create plots
    plotcslux(plotDir,daysimeter,index.daysimeter(i1));
    
end

close(gcf);

end

