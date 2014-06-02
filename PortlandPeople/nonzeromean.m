function average = nonzeromean(data)
%NONZEROMEAN Take the average of values greater than zero
%   data is a vector of real numbers

nonZeroIdx = data > 0.01;
nonZeroData = data(nonZeroIdx);
average = mean(nonZeroData);

end

