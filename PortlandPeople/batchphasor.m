function batchphasor
% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
[parentParentDir,~,~] = fileparts(parentDir);
CDFtoolkitDir = fullfile(parentParentDir,'LRC-CDFtoolkit');
PhasorToolkit = fullfile(parentParentDir,'PhasorAnalysis');
addpath(CDFtoolkitDir,PhasorToolkit);

% Specify directories
projectDir = fullfile([filesep,filesep],'root','projects',...
    'GSA_Daysimeter','Portland_Oregon_site_data',...
    'Daysimeter_People_Data');
cdfDir = fullfile(projectDir,'summerEditedData');
resultsDir = fullfile(projectDir,'summerResults');
resultsName = [datestr(now,'yyyy-mm-dd_HHMM'),'_PhasorAnalysis-sansBed'];
resultsPath = fullfile(resultsDir,resultsName);
bedLogPath = fullfile(projectDir,'summerBedLog.xlsx');

% Find CDFs in folder
listing = dir([cdfDir,filesep,'*.cdf']);
nCdf = numel(listing);

% Import the bed log
BedLog = importbedlog(bedLogPath);

% Preallocate variables
Output = struct(...
    'subject'               , {[]} ,...
    'phasorMagnitude'       , {[]} ,...
    'phasorAngleHrs'        , {[]} ,...
    'interdailyStability'   , {[]} ,...
    'intradailyVariability' , {[]} ,...
    'meanNonzeroCs'         , {[]} ,...
    'meanLogLux'            , {[]} );

for i1 = 1:nCdf
    cdfPath = fullfile(cdfDir,listing(i1).name);
    
    % Load the data
    DaysimeterData = ProcessCDF(cdfPath);
    logicalArray = logical(DaysimeterData.Variables.logicalArray);
    timeArray = DaysimeterData.Variables.time(logicalArray);
    activityArray = DaysimeterData.Variables.activity(logicalArray);
    csArray = DaysimeterData.Variables.CS(logicalArray);
    illuminanceArray = DaysimeterData.Variables.illuminance(logicalArray);
    subject = str2double(DaysimeterData.GlobalAttributes.subjectID{1});
    
    % Skip files with not enough useable data
    if numel(timeArray) < 24
        warning([listing(i1).name,' skipped due to insufficient data.']);
        continue;
    end
    
    % Select the corresponding bed log
    try
        [bedTimeArray,riseTimeArray] = selectbedlog(BedLog,subject);
    catch err
        warning(err.message);
        continue;
    end
    
    % Replace data during bed time with zero values
    [csArray,illuminanceArray,activityArray] = ...
        replacebed(timeArray,csArray,illuminanceArray,activityArray,...
        bedTimeArray,riseTimeArray);
    
    % Perform analysis
    Phasor = phasoranalysis(timeArray,csArray,activityArray);
    Average = daysimeteraverages(csArray,illuminanceArray,activityArray);
    
    % Assign results to output struct
    Output(i1,1).subject               = subject;
    Output(i1,1).phasorMagnitude       = Phasor.magnitude;
    Output(i1,1).phasorAngleHrs        = Phasor.angleHrs;
    Output(i1,1).interdailyStability   = Phasor.interdailyStability;
    Output(i1,1).intradailyVariability = Phasor.intradailyVariability;
    Output(i1,1).meanNonzeroCs         = Average.cs;
    Output(i1,1).meanLogLux            = Average.illuminance;
    Output(i1,1).meanNonzeroActivity   = Average.activity;
    
end

% Prepare results for output
OutputDataset = struct2dataset(Output);
outputCell = dataset2cell(OutputDataset);
varNameArray = outputCell(1,:);
prettyVarNameArray = lower(regexprep(varNameArray,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNameArray;
% Save results to an MS Excel file
xlswrite([resultsPath,'.xlsx'],outputCell);
% Save results to a Matlab file
save([resultsPath,'.mat'],'Output');

end