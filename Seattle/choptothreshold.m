function array = choptothreshold(array,threshold)
%CHOPTOTHRESHOLD Replace values below a threshold with the threshold value
%   Detailed explanation goes here

idx = array < threshold;
array(idx) = threshold;

end

