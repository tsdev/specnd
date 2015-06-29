function nAxis = naxis(D)
% number of points along each data axis

nDim = ndim(D);

if ishistmode(D)
    nAxis = zeros(1,nDim);
    
    for ii = 1:nDim
        nTemp = size(D.raw.axis.value{ii});
        if numel(nTemp)>2 || nTemp(2) > 1
            error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
        end
        nAxis(ii) = nTemp(1);
        
    end
else
    nAxis = repmat(size(D.raw.axis.value{1},1),[1 nDim]);
end

end