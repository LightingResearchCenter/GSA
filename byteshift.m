function byteshift(filePath,newFilePath)


Data = ProcessCDF(filePath);

timeArray = Data.Variables.time;
illuminanceArray = Data.Variables.illuminance;
claArray = Data.Variables.CLA;
csArray = Data.Variables.CS;
activityArray = Data.Variables.activity;

% Remove zero reset values
Anext = [activityArray(2:end);activityArray(end)];
activityArray(activityArray==0) = Anext(activityArray==0);

% diffLux = diff(log2(illuminanceArray));
% diffLux2 = diffLux(2:end);
% diffLux = diffLux(1:end-1);
% 
% qup = find(diffLux >= 6 | (diffLux > 2 & diffLux2 > 2));
% qup(illuminanceArray(qup)==0) = []; % remove zero values introduced by resets
% qdn = find(diffLux < -6);

actOver = activityArray >=1;

diffAct = diff(actOver);
diffAct2 = diffAct(2:end);
diffAct = diffAct(1:end-1);

qup = find(diffAct > 0);
qdn = find(diffAct < 0);
h1 = 1;
while h1 < numel(qup)
    if qup(h1+1) < qdn(find(qdn>qup(h1),1,'first')) || qup(h1+1) < qup(h1)+22
        qup(h1+1) = [];
    else
        h1 = h1 + 1;
    end
end

qdn2 = zeros(size(qup));
for h2 = 1:numel(qup)
    if h2 < numel(qup)
        qdn2(h2) = max(qdn(qdn>qup(h2) & qdn<qup(h2+1)));
    else
        if ~any(qdn>qup(h2))
            qup(h2) = [];
            qdn2(h2) = [];
        else
            qdn2(h2) = max(qdn(qdn>qup(h2)));
        end
    end
end
qdn = qdn2;

LuxFix = illuminanceArray;
AFix = activityArray;
CSFix = csArray;
CLAFix = claArray;
for i1 = 1:length(qup)
    index1 = qup(i1);
    index2 = qdn(i1);
    if isempty(index2)
        break;
    end
    index1b = index1-5;
    index2b = index2+5;
    segmentLux = illuminanceArray(index1b:index2b);
    segmentA = activityArray(index1b:index2b);
    if ((timeArray(index2)-timeArray(index1)) > 5/24)
        continue;
    end
    segmentAa = activityArray(index1:index2);
    Correlation = corr([segmentLux,segmentA]);
    Correlation = Correlation(2,1); % element [2,1] of correlation matrix returned above
    STD = std(segmentAa)/mean(segmentAa);
    
%     if (Correlation > 0.70 || mean(segmentAa) < 0.02 || min(segmentAa) ==0 || STD < 0.01)
      if (index1>10 && index2<(length(illuminanceArray)-10))
        LuxFix(index1:index2) = mean([illuminanceArray(index1-11:index1-2);illuminanceArray(index2+2:index2+11)]);
        CLAFix(index1:index2) = mean([claArray(index1-11:index1-2);claArray(index2+2:index2+11)]);
        CSFix(index1:index2) = mean([csArray(index1-11:index1-2);csArray(index2+2:index2+11)]);
        AFix(index1:index2) = mean([activityArray(index1-11:index1-2);activityArray(index2+2:index2+11)]);
      end
%     end
end

Data.Variables.time = timeArray(:);
Data.Variables.illuminance = LuxFix(:);
Data.Variables.CLA = CLAFix(:);
Data.Variables.CS = CSFix(:);
Data.Variables.activity = AFix(:);

Data.Variables.logicalArray = true(size(timeArray));

if strcmp(newFilePath,filePath)
    delete(filePath);
end

RewriteCDF(Data,newFilePath)

end
