function Paths = initializepaths(location,session)
%INITIALIZEPATHS Prepare GSA folder and file paths
%   Detailed explanation goes here

% Preallocate output structure
Paths = struct(...
    'gsa'           ,'',...
    'location'      ,'',...
    'originalData'  ,'',...
    'editedData'    ,'',...
    'correctedData' ,'',...
    'results'       ,'',...
    'plots'         ,'',...
    'logs'          ,'');

% Retain only alphabetic characters from input and convert to lowercase
location = lower(regexprep(location,'\W',''));
session  = lower(regexprep(session,'\W',''));

% Set GSA parent directory
Paths.gsa = fullfile([filesep,filesep],'root','projects','GSA_Daysimeter');
% Check that it exists
if exist(Paths.gsa,'dir') ~= 7 % 7 = folder
    error(['Cannot locate the folder: ',Paths.gsa]);
end

% Specify location directory
switch location
    case {'grandjunction','colorado','co'}
        Paths.location = fullfile(Paths.gsa,...
            'GrandJunction_Colorado_site_data','Daysimeter_Stationary_Data');
    case {'portland','oregon','or'}
        Paths.location = fullfile(Paths.gsa,...
            'Portland_Oregon_site_data','Daysimeter_Stationary_Data');
    case {'seattle','washingtion','wa'}
        Paths.location = fullfile(Paths.gsa,...
            'Seattle_Washington','Daysimeter_Stationary_Data');
    case {'dc1800f'}
        Paths.location = fullfile(Paths.gsa,...
            'WashingtonDC','Daysimeter_Stationary_Data');
    case {'dcrob'}
        Paths.location = fullfile(Paths.gsa,...
            'WashingtonDC-RegionalOfficeBldg-7th&Dstreet','Daysimeter_Stationary_Data');
    otherwise
        error('Unknown project.');
end

% Specify session specific directories
Paths.originalData = fullfile(Paths.location,[session,'OriginalData']);
Paths.editedData   = fullfile(Paths.location,[session,'EditedData']);
Paths.results      = fullfile(Paths.location,[session,'Results']);
Paths.plots        = fullfile(Paths.location,[session,'Plots']);
Paths.logs         = fullfile(Paths.location,[session,'Logs']);

Paths.correctedData   = fullfile(Paths.location,[session,'CorrectedData']);

if exist(Paths.correctedData,'dir') ~= 7
    mkdir(Paths.correctedData);
end

end

