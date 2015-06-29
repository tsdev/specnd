function nDim = ndim(D)
% number of data axis

if ishistmode(D)
    % gives 0 dim for empty object
    nDim = sum(cellfun(@(C)~isempty(C),D.raw.axis.value));
    %nDim = numel(D.raw.axis.value);
else
    nDim = size(D.raw.axis.value{1},2);
end

end