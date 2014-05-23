function initializefigure
%INITIALIZEFIGURE Summary of this function goes here
%   Detailed explanation goes here

h = figure;
width = 6.5;
height = 4;
figPosition = [2,2,width,height];
paperSize = [width,height];
paperPosition = [0,0,width,height];
set(h,'Units','inches','Position',figPosition);
set(h,'PaperUnits','inches','PaperSize',paperSize,'PaperPosition',paperPosition);

end

