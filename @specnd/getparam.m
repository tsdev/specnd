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
    % doesn't work, stupid Matlab struct() function
    %sField = [D.raw.param.name; D.raw.param.value];
    %varargout{1} = struct(sField{:});
    
    % loop over all variable
    param = struct;
    for ii = 1:numel(D.raw.param.name)
        param.(D.raw.param.name{ii}) = D.raw.param.value{ii};
    end
    
    
    
    if nargout == 0
        varargout{1} = struct2table(param);
    else
        varargout{1} = param;
    end
    
    if nargout > 1
        varargout{2} = D.raw.param.label;
    end
    return
end

% find a given parameter
% index of parameter
pIdx = find(strcmp(D.raw.param.name,pName));

if numel(pIdx)==0
    warning('specnd:ParameterMissing','The parameter does not exists.');
    varargout = {};
    if nargout > 1
        varargout{2} = {};
    end
else
    varargout{1} = D.raw.param.value{pIdx(1)};
    if nargout > 1
        varargout{2} = D.raw.param.label{pIdx(1)};
    end
    if numel(pIdx) > 1
        warning('specnd:MultipleParameter','Multiple parameters exist with the same name, returning the first only.')
    end
end

end