function organizeExcel(inputFile)
%ORGANIZEEXCEL Organize input data and save to Excel
%   Format for Mariana
load(inputFile);
saveFile = regexprep(inputFile,'\.mat','\.xlsx');
inputData = struct2dataset(output);
clear output;

% Determine variable names
varNames = get(inputData,'VarNames');

% Create header labels
% Make variable names pretty
prettyNames = lower(regexprep(varNames,'([^A-Z])([A-Z])','$1\r\n$2'));

% Convert inputData to cells
dataCell = dataset2cell(inputData);
dataCell(1,:) = prettyNames; % Replace variable names

% Write to file
xlswrite(saveFile,dataCell); % Create sheet1

end

