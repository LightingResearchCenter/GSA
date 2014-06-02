function [csArray,illuminanceArray,activityArray] = replacebed(timeArray,csArray,illuminanceArray,activityArray,bedTimeArray,riseTimeArray)
%
%

% Preallocate the logical index
bedIdx = false(size(timeArray));
% Add indexes for daytime of each day
for i1 = 1:numel(bedTimeArray)
    bedIdx = bedIdx | (timeArray >= bedTimeArray(i1) & timeArray <= riseTimeArray(i1));
end

% Replace in bed time
csArray(bedIdx) = 0;
illuminanceArray(bedIdx) = 0;
activityArray(bedIdx) = 0;

end

