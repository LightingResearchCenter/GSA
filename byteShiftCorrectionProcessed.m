function [newFileName] = byteShiftCorrectionProcessed()

[fileName,pathName] = uigetfile('*.*','Calibrated Daysimeter File');
filePathName = [pathName,'\',fileName];
%filePathName = '\\root\projects\GSA_Daysimeter\Colorado Daysimeter data\processedData\subject05Processed.txt';
[Date,Time,Lux,CLA,CS,A] = textread(filePathName,'%s%s%f%f%f%f','headerlines',1);

timeStart = datenum([Date{1},' ',Time{1}],'mm/dd/yyyy HH:MM:SS');
deltaTime = datenum([Date{2},' ',Time{2}],'mm/dd/yyyy HH:MM:SS') - timeStart;
time = timeStart + deltaTime*(0:length(Lux)-1)';
%time = 1:length(Lux);

% Remove zero reset values
Anext = [A(2:end);A(end)];
A(A==0) = Anext(A==0);

figure(1)
set(gcf,'Position',[ 15,501,1236,420]);
semilogy(time,Lux,'r-')
hold on
semilogy(time,A,'g-')
hold off
datetick2('x')

diffLux = diff(log2(Lux));
diffLux2 = diffLux(2:end);
diffLux = diffLux(1:end-1);
%{
figure(4)
plot(diffLux,'r')
hold on
plot(diffLux2,'b')
hold off
%}
%qup = find(diff(log2(Lux)) > 6);
qup = find(diffLux >= 6 | (diffLux > 2 & diffLux2 > 2));
qup(Lux(qup)==0) = []; % remove zero values introduced by resets
%qdn = find(diff(log2(Lux)) <= -5);
qdn = find(diffLux < -6);
figure(1)
hold on
h1 = semilogy(time(qup),1,'gd');
set(h1,'MarkerFaceColor','g')
h2 = semilogy(time(qdn),1,'kd');
set(h2,'MarkerFaceColor','k');
%{
aup = find(diff(log2(A)) > 3);
adn = find(diff(log2(A)) < -3);
h1 = semilogy(time(aup),.01,'gd');
set(h1,'MarkerFaceColor','g')
h2 = semilogy(time(adn),.01,'kd');
set(h2,'MarkerFaceColor','k')
hold off
%}
LuxFix = Lux;
AFix = A;
CSFix = CS;
CLAFix = CLA;
for i1 = 1:length(qup)
    index1 = qup(i1);
    index2 = qdn(find(qdn>index1,1,'first'));
    if isempty(index2)
        break;
    end
    index1b = index1-5;
    index2b = index2+5;
    segmentLux = Lux(index1b:index2b);
    segmentA = A(index1b:index2b);
    if ((time(index2)-time(index1)) > 5/24)
        continue;
    end
    segmentAa = A(index1:index2);
    Correlation = corr([segmentLux,segmentA]);
    Correlation = Correlation(2,1); % element [2,1] of correlation matrix returned above
    STD = std(segmentAa)/mean(segmentAa);
    %{
    figure(2)
    plot(time(index1b:index2b),segmentLux,'b.-')
    figure(3)
    plot(time(index1b:index2b),segmentA,'r.-')
    %}
    if (Correlation > 0.70 || mean(segmentAa) < 0.02 || min(segmentAa) ==0 || STD < 0.01)
      if (index1>10 && index2<(length(Lux)-10))
        LuxFix(index1:index2) = mean([Lux(index1-11:index1-2);Lux(index2+2:index2+11)]);
        CLAFix(index1:index2) = mean([CLA(index1-11:index1-2);CLA(index2+2:index2+11)]);
        CSFix(index1:index2) = mean([CS(index1-11:index1-2);CS(index2+2:index2+11)]);
        AFix(index1:index2) = mean([A(index1-21:index1-2);A(index2+2:index2+21)]);
      end
    end
    %pause
end
figure(1)
hold on
semilogy(time,LuxFix,'b-')
semilogy(time,AFix,'k-')
hold off

newFileName = ['byteShiftCorrected',fileName];
newPathFileName = [pathName,'\',newFileName];
fid = fopen(newPathFileName,'w');
fprintf(fid,'%s\t%s\t%s\t%s\t%s\r\n','Time','Lux','CLA','CS','Activity');
for i1 = 1:length(Lux)
    fprintf(fid,'%s%s%s\t%f\t%f\t%f\t%f\r\n',Date{i1},' ',Time{i1},LuxFix(i1),CLAFix(i1),CSFix(i1),AFix(i1));
end
fclose(fid);
disp([newFileName,' saved to same folder']);
