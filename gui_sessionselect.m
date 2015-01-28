function [plainSession,varargout] = gui_sessionselect
%GUI_SESSIONSELECT GUI to select desired session
%   Detailed explanation goes here

plainSessionArray   = {'summer','winter','november','december'};
displaySessionArray = {'Summer','Winter','November','December'};

choice = menu('Choose a project session',displaySessionArray);

plainSession   = plainSessionArray{choice};
displaySession = displaySessionArray{choice};

if nargout == 2
    varargout{1} = displaySession;
end

end

