function nCh = nch(D)
% number of data channels

nTemp = size(D.raw.channel.value);
if numel(nTemp)>2 || nTemp(2)~=1
    error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
end
nCh = max(D.raw.channel.value);


end