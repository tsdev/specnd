function nAxis = naxis(D)
% number of points along each data axis

nDim = ndim(D);

nAxis = zeros(1,nDim);

subField  = {'value' 'name' 'label'};

for ii = 1:numel(subField)
    
    nTemp = size(D.raw.axis.(subField{ii}));
    
    if ~iscell(D.raw.axis.(subField{ii})) || numel(nTemp)>2 || nTemp(1)~=1 || nTemp(2)~=nDim
        error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
    end
    
end

for ii = 1:nDim
    nTemp = size(D.raw.axis.value{ii});
    if numel(nTemp)>2 || nTemp(1)~=1
        error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
    end
    nAxis(ii) = nTemp(2);
    
end

end