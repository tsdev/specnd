function [val,opt] = findoption(varargin)
% separates input arguments before first string and after

aIdx = find(cellfun(@(C)ischar(C),varargin),1,'first');

if ~isempty(aIdx)
    val = varargin(1:(aIdx-1));
    opt = varargin(aIdx:end);
else
    val = varargin;
    opt = {};
end

end