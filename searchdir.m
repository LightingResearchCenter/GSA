function [fileNameArray,filePathArray] = searchdir(directory,extension)
%SEARCHDIR Search a directory for files matching a specified extension
%   Only searches the first level of the directory. Returns a cell array of
%   the file names and a cell array of full file paths.

% Retain only alphabetic characters from input and convert to lowercase
extension = lower(regexprep(extension,'\W',''));

% Perform the search
Listing = dir([directory,filesep,'*.',extension]);

% Extract file names
listingCell = struct2cell(Listing);
fileNameArray = listingCell(1,:)';

% Construct full file paths
filePathArray = fullfile(directory,fileNameArray);

end

