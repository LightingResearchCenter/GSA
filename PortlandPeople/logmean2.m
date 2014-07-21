function average = logmean2(data)
%LOGMEAN Transform data to log space take the mean and untransform
%   data is a vector of real numbers
data(data<0.01) = 0.01;
logData = log(data);
averageLog = mean(logData);
average = exp(averageLog);

end

