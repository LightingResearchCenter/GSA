function data = trimdata(data,startTime,stopTime)
%TRIMDATA Summary of this function goes here
%   Detailed explanation goes here

idx = data.time >= startTime & data.time <= stopTime;

variableNameArray = fieldnames(data);
n = numel(variableNameArray);

for i1 = 1:n
    temp = data.(variableNameArray{i1});
    data.(variableNameArray{i1}) = temp(idx,:);
end

end

