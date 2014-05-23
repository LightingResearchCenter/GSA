function daysimeter = importprocesseddaysimeter(filename, startRow, endRow)
%IMPORTDAYSIMETER Import numeric data from a text file as column vectors.
%   daysimeter = IMPORTFILE(FILENAME) Reads data from text file FILENAME 
%   for the default selection.
%
%   daysimeter = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from
%   rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   daysimeter =
%   importfile('byteShiftCorrectedDay31_140314_1055_processed.txt',2,
%   14870);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2014/03/27 14:54:03

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
timeStrArray = dataArray{:, 1};
timeArray = datenum(timeStrArray);
daysimeter = struct;
daysimeter.time     = timeArray;
daysimeter.lux      = dataArray{:, 2};
daysimeter.cla      = dataArray{:, 3};
daysimeter.cs       = dataArray{:, 4};
daysimeter.activity	= dataArray{:, 5};

end

