function validate(D)
% validates specnd object raw property
%
% VALIDATE(D)
%

mainField     = {'datcnt' 'errmon' 'g' 'axis' 'channel' 'param' 'log' 'fit'};
nMainField    = numel(mainField);
checkSubField = [    true     true true   true      true    true false false];
subField  = {'value' 'name' 'label'};

% check that all necessary fields are there
isMainField = isfield(D.raw,mainField);
if ~all(isMainField)
    error('specnd:MissingField','Necessary field(s) of D.raw are missing!');
end

% check that all necessary subfields are there
for ii = 1:nMainField
    if checkSubField(ii)
        isSubField = isfield(D.raw.(mainField{ii}),subField);
        if ~all(isSubField)
            idx = find(isSubField==0,1);
            error('specnd:MissingSubField','Necessary subfield D.raw.%s.%s is missing!',mainField{ii},subField{idx});
        end
    end
end

% datcnt and errmon
isgrid = isgridmode(D);
nCh    = nch(D);
nAxis  = naxis(D);


nAxis2 = size(D.raw.datcnt.value);
nAxis3 = size(D.raw.errmon.value);

% check data dim == error dim
if (numel(nAxis2)~=numel(nAxis3)) || any(nAxis2-nAxis3)
    error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
end

if isgrid
    
    % remove the stupid 2nd dimension of column vectors (Matlab shit)
    if numel(nAxis2) == 2 && nAxis2(2) == 1
        nAxis2 = nAxis2(1);
    end
    
    nAxis = [nAxis nCh];
    
    if any(nAxis(1:numel(nAxis2))-nAxis2) || any(nAxis((numel(nAxis2)+1):end)~=1)
        error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
    end
    
    % check g-tensor dimensions
    nG = size(D.raw.g.value);
    if numel(nG)>2 || nG(1)~=nG(2) || nG(1)~=ndim(D)
        error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
    end
    
else
    nPoint = nAxis2(2);
    if nAxis2(1)~=1 || numel(Axis2)>2  || nAxis2(2)~=nPoint || any(nAxis-nPoint) || numel(D.raw.channel.value)~=nPoint
        error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
    end
    
end

end