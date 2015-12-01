function [val, label] = getpar_D20(dat,parName)
% get one or multiple parameters of one or multiple files
%

if ~iscell(dat)
    dat = {dat};
end

if ~iscell(parName)
    parName = {parName};
end

nDat = numel(dat);
nPar = numel(parName);

val = zeros(nPar,nDat);
label = cell(1,nPar);

for ii = 1:nPar
    pIdx = find(strcmp({dat{1}.par(:).name},parName{ii}));
    
    if isempty(pIdx)
        error('getpar_D20:MissingParameter','The requested parameter is missing!')
    end
    
    for jj = 1:nDat
        pTemp = dat{jj}.par(pIdx).value;
        if isempty(pTemp) || ~isnumeric(pTemp)
            val(ii,jj) = nan;
        else
            val(ii,jj) = pTemp;
        end
    end
    
    if nargout > 1
        label{ii} = dat{1}.par(pIdx).label;
    end
end

if nargout > 1 && nPar == 1
    label = label{1};
end

end