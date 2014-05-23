function plotcslux(plotDir,daysimeter,daysimeterSN)
%PLOTCSLUX Summary of this function goes here
%   Detailed explanation goes here

daysimeterSN = num2str(daysimeterSN);

daysimeterLabel = ['Daysimeter ',daysimeterSN];
dateRange = [datestr(daysimeter.time(1)),' - ',datestr(daysimeter.time(end))];
luxTitle = {[daysimeterLabel,' - Illuminance'];dateRange};
csTitle = {[daysimeterLabel,' - Circadian Stimulus'];dateRange};

luxPath = fullfile(plotDir,['daysimeter',daysimeterSN,'lux.png']);
csPath	= fullfile(plotDir,['daysimeter',daysimeterSN,'cs.png']);

x = daysimeter.time - floor(min(daysimeter.time));

xMin = 0;
xMax = ceil(max(x));
xTickArray = xMin:xMax;
csTickArray = 0:0.1:0.7;

plot(x,daysimeter.cs,'-k','LineWidth',1);
title(csTitle);
ylabel('CS');
xlabel('days');
set(gca,'Box','off','TickDir','out','XTick',xTickArray,'YTick',csTickArray);
xlim([xMin,xMax]);
savefigure(csPath);
clf;

semilogy(x,daysimeter.lux,'-k','LineWidth',1);
title(luxTitle);
ylabel('lux');
xlabel('days');
set(gca,'Box','off','TickDir','out','XTick',xTickArray);
xlim([xMin,xMax]);
yLim = get(gca,'YLim');
ylim([0.005,yLim(2)]);
set(gca,'YMinorTick','off');
savefigure(luxPath)
clf;

end

