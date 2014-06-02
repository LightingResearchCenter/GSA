function average = logmean(data)
%LOGMEAN Transform data to log space take the mean and untransform
%   data is a vector of real numbers

nonZeroIdx = data >= 0.01;
nonZeroData = data(nonZeroIdx);
logData = log(nonZeroData);
averageLog = mean(logData);
average = exp(averageLog);

end

