function dateRange = dateRangeCheck
%AVERAGEDATA Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
[plainLocation,~] = gui_locationselect;
[plainSession ,~ ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[~,cdfPathArray] = searchdir(Paths.editedData,'cdf');

nFiles = numel(cdfPathArray);
dateRange = cell(nFiles+1,3);
dateRange{1,1} = 'location';
dateRange{1,2} = 'start date';
dateRange{1,3} = 'end date';
for i1 = 1:nFiles
    % Import data
    cdfData = daysimeter12.readcdf(cdfPathArray{i1});
    [absTime,~,~,~,~,masks,locationID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
    newLogicalArray  = masks.observation & masks.compliance;
    timeArray        = absTime.localDateNum(newLogicalArray);
    
    
    % Crop DC December 2014
    if strcmpi(plainLocation,'dc') && strcmpi(plainSession,'december')
        keepIdx = timeArray > datenum(2014,12,4) & timeArray < datenum(2014,12,20);
        timeArray = timeArray(keepIdx);
    end
    
    % Remove holidays
    removeIdx = timeArray >= datenum(2015,7,3) & timeArray < datenum(2015,7,4);
    timeArray = timeArray(~removeIdx);
    
    dateRange{i1+1,1} = locationID;
    dateRange{i1+1,2} = datestr(min(timeArray));
    dateRange{i1+1,3} = datestr(max(timeArray));

end


end

