function [output] = AnalyzeFile(subject,Time,Activity,bedTime,wakeTime)

% Set analysis start and end times
analysisStartTime = bedTime - 20/60/24;
analysisEndTime = wakeTime + 20/60/24;

% Find analysis times outside of data
idx1 = (analysisStartTime < Time(1)) | (analysisStartTime > Time(end));
idx2 = (analysisEndTime   < Time(1)) | (analysisEndTime   > Time(end));
idx3 = idx1 | idx2;

% Remove times out of range
bedTime(idx3) = [];
wakeTime(idx3) = [];
analysisStartTime(idx3) = [];
analysisEndTime(idx3) = [];

nNights = numel(bedTime);

%% Preallocate sleep parameters
output = cell(nNights,1);

dateFormat = 'dd-mmm-yy';

%% Call function to calculate sleep parameters for each day
for i1 = 1:nNights
    try
        output{i1} = sleepAnalysis(Time,Activity,...
                analysisStartTime(i1),analysisEndTime(i1),...
                bedTime(i1),wakeTime(i1),'auto');
    catch err
        display(err.message);
    end
    
    tempFields = fieldnames(output{i1})';
    
    output{i1}.line = subject + i1/10;
    output{i1}.subject = subject;
    output{i1}.date = datestr(floor(analysisStartTime(i1)),dateFormat);
    
    output{i1} = orderfields(output{i1},[{'line','subject','date'},tempFields]);
end

end