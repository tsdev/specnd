function nDim = ndim(D)
% number of data axis

if ishistmode(D)
    nDim = numel(D.raw.axis.value);
else
    nDim = size(D.raw.axis.value{1},2)-1;
end

end