function averageStruct = stickaverage(stickStruct)
%STICKAVERAGE Summary of this function goes here
%   Detailed explanation goes here

hourArray = stickStruct.hour;
fieldsToRm = {'daysimeter','mountStyle','orientation','hour'};
stickStruct = rmfield(stickStruct,fieldsToRm);

varNameArray = fieldnames(stickStruct);
nVar = numel(varNameArray);

template = ['hour',varNameArray'];
template(2,1) = {[]};
averageStruct = struct(template{:});

averageStruct.hour = (0:23)';

varsToLogAverage = {'luxCloudy','claCloudy','luxSunny','claSunny'};

for i1 = 1:numel(averageStruct.hour)
    for i2 = 1:nVar
        tempArray = stickStruct.(varNameArray{i2});
        idxHour = hourArray == averageStruct.hour(i1);
        idxNaN = isnan(tempArray);
        idx = idxHour & ~idxNaN;
        
        if any(strcmpi(varNameArray{i2},varsToLogAverage))
            averageStruct.(varNameArray{i2})(i1,1) = logaverage(tempArray(idx));
        else
            averageStruct.(varNameArray{i2})(i1,1) = mean(tempArray(idx));
        end
    end
end

end

