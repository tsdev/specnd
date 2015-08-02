function validate(D)
% validates specnd object raw property
%
% VALIDATE(D)
%

mainField     = {'sig' 'g' 'ch' 'par'};
nMainField    = numel(mainField);
subField      = {'val' 'name' 'label'};

% check that all necessary fields are there
isMainField = isfield(D.raw,mainField);
if ~all(isMainField)
    error('specnd:validate:MissingField','Necessary field(s) of of the specnd object are missing!');
end

% check that all necessary subfields are there
for ii = 1:nMainField
    if ii == 1
        subField0 = [subField {'err' 'mon'}];
    else
        subField0 = subField;
    end
    isSubField = isfield(D.raw.(mainField{ii}),subField0);
    if ~all(isSubField)
        idx = find(isSubField==0,1);
        error('specnd:validate:MissingSubField','Necessary subfield D.raw.%s.%s is missing!',mainField{ii},subField0{idx});
    end
end

% check that monitor and error have the same dimensions as the signal value
if numel(D.raw.sig.err) ~= 1
    if any(size(D.raw.sig.val) ~= size(D.raw.sig.err))
        error('specnd:validate:WrongDim','Dimensions of signal value and error don''t agree!');
    end
end
if numel(D.raw.sig.mon) ~= 1
    if any(size(D.raw.sig.val) ~= size(D.raw.sig.mon))
        error('specnd:validate:WrongDim','Dimensions of signal value and monitor don''t agree!');
    end
end

% get different parameters of the object
nCh    = nch(D);
nAxis  = naxis(D);

% check that all struct is a column vector
sSize = structfun(@(S)size(S,2),D.raw);

if any(sSize>1)
    error('specnd:validate:WrongDim','Wrong dimensions of one of the subfields!')
end

if ishistmode(D)
    
    
    for ii = 1:numel(D.raw.ax)
        if nAxis(ii) ~= size(D.raw.sig.val,ii)
            error('specnd:validate:WrongDim','Signal and axis dimensions are incompatible!');
        end
    end
    
    % check g-tensor dimensions
    nG = size(D.raw.g.val);
    if numel(nG)>2 || nG(1)~=nG(2) || (numel(D.raw.g.val)>1 && nG(1)~=ndim(D))
        error('specnd:WrongDim','Signal and g-tensor dimensions are incompatible!');
    end
    
else
    %nPoint = nAxis2(1);
    %if nAxis2(2)~=1 || numel(nAxis2)>2  || any(nAxis-nPoint) || numel(D.raw.channel.value)~=nPoint
    %    error('specnd:WrongDim','Data, error, channel, g or axis dimensions are incompatible!');
    %end
    
end

end