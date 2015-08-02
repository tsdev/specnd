function varargout = getparam(D,pName)
% get parameter value stored in a specnd object
%
% [value, {label}] = GETPARAM(D,{pName})
%
% Input:
%
% D         Specnd object.
% pName     Name of the parameter.
%
% Output:
%
% value     Value that belongs to the parameter with the given name.
% label     Label (longer text) that belongs to the parameter with the
%           given name, case sensitive, optional.
%
%
% param = GETPARAM(D)
%
% Returns all parameter values.
%
% Output:
%
% param     Structure that contains all parameter name as a field and
%           values.
%
% See also specnd.setparam.
%

% returns all parameter name-value pairs in a struct
if nargin == 1
    % NO LOOP :P
    parCell = {D.raw.par(:).name;D.raw.par(:).val};
    param = struct(parCell{:});
    
    varargout{1} = param;
    
    if nargout > 1
        varargout{2} = D.raw.param.label;
    end
    return
end

% find a given parameter
% index of parameter
pIdx = find(strcmp({D.raw.par(:).name},pName));

if numel(pIdx)==0
    warning('specnd:getparam:ParameterMissing','The requested parameter does not exists.');
    varargout = {};
    if nargout > 1
        varargout{2} = {};
    end
else
    varargout{1} = D.raw.par(pIdx(1)).val;
    if nargout > 1
        varargout{2} = D.raw.par(pIdx(1)).label;
    end
    if numel(pIdx) > 1
        warning('specnd:getparam:MultipleParameter','Multiple parameters exist with the same name, returning the first only.')
    end
end

end