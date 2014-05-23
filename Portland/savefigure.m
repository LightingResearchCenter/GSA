function savefigure(filePath)
%SAVEFIGURE Summary of this function goes here
%   Detailed explanation goes here

h = gcf;
print(h,filePath,'-dpng','-r200');

end

