function nDim = ndim(D)
% number of data axis

% gives 0 dim for empty object
nDim = numel(D.raw.ax);

end