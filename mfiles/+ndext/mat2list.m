function varargout = mat2list(M,dim)
% create list from an array by splitting it up along a selected dimension
%
% [arg1, arg2, arg3, ...] = mat2list(M,dim)
%
% the number of output arguments should be equal to the size of the matrix
% along the selected dimension

sM = num2cell(size(M));
sM{dim} = ones(1,sM{dim});

varargout = mat2cell(M,sM{:});

end