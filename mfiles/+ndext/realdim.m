function dim = realdim(M)
% returns the real number of dimension of a matrix
% for column vector M = ones(3,1)
% >> realdim(M)
% >> ans = 1
%
% for empty matrices the realdim is 0. For any other array shape it returns
% the same value as ndims
%

if numel(M) == 0
    dim = 0;
    return
end

dim = ndims(M);

if dim == 2 && size(M,2) == 1
    dim = 1;
end

end