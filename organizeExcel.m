function organizeExcel(inputFile)
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana
load(inputFile);
saveFile = regexprep(inputFile,'\.mat','\.xlsx');

flatOut = cat(1,output{:});
% Determine variable names
varNames = fieldnames(flatOut{1})';
% Make variable names pretty
prettyNames = lower(regexprep(varNames,'([^A-Z])([A-Z])','$1 $2'));

% Convert nested cell array of structs to 2D cell matrix
tempCell = cellfun(@struct2cell,flatOut,'UniformOutput',false);
tempCell2 = cat(2,tempCell{:})';

% Combine variable names with the data
cellOut = [prettyNames;tempCell2];

% Write to file
xlswrite(saveFile,cellOut); % Create sheet1

end

