function nAxis = naxis(D)
% number of points along each data axis

nDim = ndim(D);

nAxis = cellfun(@(C)numel(C),{D.raw.ax(:).val});

end