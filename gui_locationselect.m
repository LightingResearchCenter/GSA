function [plainLocation,varargout] = gui_locationselect
%GUI_LOCATIONSELECT GUI to select the desired project
%   Detailed explanation goes here

plainLocationArray  = {'grandjunction','portland','seattle'};
diplayLocationArray = {'Grand Junction, CO','Portland, OR','Seattle, WA'};

choice = menu('Choose a project location',diplayLocationArray);

plainLocation   = plainLocationArray{choice};
displayLocation = diplayLocationArray{choice};

if nargout == 2
    varargout{1} = displayLocation;
end

end

