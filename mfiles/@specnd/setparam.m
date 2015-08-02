function D = setparam(D,pName,pVal,pLabel)
% add/change parameter value stored in a specnd object
%
% D = SETPARAM(D,pName,pVal,{pLabel})
%
% Input:
%
% D         Specnd object.
% pName     Name of the parameter.
% pVal      New value of the parameter.
% pLabel    New label string for the parameter, optional.
%
% Output:
% D         Output specnd object with the modified parameter.
%
% See also specnd.getparam.
%

% index of parameter
pIdx = find(strcmp({D.raw.par(:).name},pName));

if nargin < 4
    pLabel = '';
end

if numel(pIdx)==0
    % adding new parameter value
    D.raw.par(end+1).val = pVal;
    D.raw.par(end).name  = pName;
    D.raw.par(end).label = pLabel;
elseif numel(pIdx)==1
    % changing existing parameter
    D.raw.par(pIdx).val   = pVal;
    if nargin >= 4
        D.raw.par(pIdx).label = pLabel;
    end
elseif numel(pIdx>1)
    % multiple parameters with the same name
    % clearing up the mess
    D.raw.par(pIdx(1)).name = pName;
    D.raw.par(pIdx(1)).val  = pVal;
    if nargin >= 4
        D.raw.par(pIdx(1)).label = pLabel;
    end
    
    % clearing multiple variables
    D.raw.par(pIdx(2:end)) = [];
    
    warning('specnd:MultipleParameter','Multiple parameters exist with the same name, removing duplicates.')
end

end