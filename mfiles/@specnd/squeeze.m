function squeeze(D)
% remove data dimensions with a single coordinate value

if ishistmode(D)
    % find singleton indices
    singlIdx = find(size(D) == 1);
    dimVect = 1:ndims(D);
    dimVect(singlIdx) = [];
    D.raw.datcnt.value = squeeze(permute(D.raw.datcnt.value,[dimVect singlIdx]));
    D.raw.errmon.value = squeeze(permute(D.raw.errmon.value,[dimVect singlIdx]));
    
    D.raw.axis.value = D.raw.axis.value(dimVect);
    D.raw.axis.name  = D.raw.axis.name(dimVect);
    D.raw.axis.label = D.raw.axis.label(dimVect);
    
else
    % TODO
end

end