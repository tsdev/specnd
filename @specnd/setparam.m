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
pIdx = find(strcmp(D.raw.param.name,pName));

if nargin < 4
    pLabel = '';
end

if numel(pIdx)==0
    % adding new parameter value
    D.raw.param.name{end+1}  = pName;
    D.raw.param.value{end+1} = pVal;
    D.raw.param.label{end+1} = pLabel;
elseif numel(pIdx)==1
    % changing existing parameter
    D.raw.param.name{pIdx}  = pName;
    D.raw.param.value{pIdx} = pVal;
    D.raw.param.label{pIdx} = pLabel;
elseif numel(pIdx>1)
    % multiple parameters with the same name
    % clearing up the mess
    D.raw.param.name{pIdx(1)}  = pName;
    D.raw.param.value{pIdx(1)} = pVal;
    D.raw.param.label{pIdx(1)} = pLabel;
    
    % clearing multiple variables
    D.raw.param.name(pIdx(2:end))  = [];
    D.raw.param.value(pIdx(2:end)) = [];
    D.raw.param.label(pIdx(2:end)) = [];
    
    warning('specnd:MultipleParameter','Multiple parameters exist with the same name, removing duplicates.')
end

end