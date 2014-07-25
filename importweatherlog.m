function sunnyDayArray = importweatherlog(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   [Date1,Condition] = IMPORTFILE(FILE) reads data from the first
%   worksheet in the Microsoft Excel spreadsheet file named FILE and
%   returns the data as column vectors.
%
%   [Date1,Condition] = IMPORTFILE(FILE,SHEET) reads from the specified
%   worksheet.
%
%   [Date1,Condition] = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from
%   the specified worksheet for the specified row interval(s). Specify
%   STARTROW and ENDROW as a pair of scalars or vectors of matching size
%   for dis-contiguous row intervals. To read to the end of the file
%   specify an ENDROW of inf.
%
%	Date formatted cells are converted to MATLAB serial date number format
%	(datenum).
%
% Example:
%   [Date1,Condition] = importfile('weatherLog.xlsx','Sheet1',2,23);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2014/07/25 12:36:01

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    endRow = 23;
end

%% Import the data, extracting spreadsheet dates in MATLAB serial date number format (datenum)
[~, ~, raw, dateNums] = xlsread(workbookFile, sheetName, sprintf('A%d:B%d',startRow(1),endRow(1)),'' , @convertSpreadsheetDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:B%d',startRow(block),endRow(block)),'' , @convertSpreadsheetDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dateNums = [dateNums;tmpDateNumBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,2);
raw = raw(:,1);
dateNums = dateNums(:,1);

%% Replace date strings by MATLAB serial date numbers (datenum)
R = ~cellfun(@isequalwithequalnans,dateNums,raw) & cellfun('isclass',raw,'char'); % Find spreadsheet dates
raw(R) = dateNums(R);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
Date1 = data(:,1);
Condition = cellVectors(:,1);

%% Select only sunny days
sunnyDayIdx = strcmpi('sunny',Condition);
sunnyDayArray = Date1(sunnyDayIdx);
