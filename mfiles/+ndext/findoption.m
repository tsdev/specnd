function optIdx = findoption(varargin)
% finds the index of the first string argument in a list of arguments
%
% optIdx = findoption(...)
%

optIdx = find(cellfun(@(C)ischar(C),varargin),1,'first');

if isempty(optIdx)
    optIdx = nargin+1;
end

end