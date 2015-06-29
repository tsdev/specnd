function D = realdim(M)
% returns the real number of dimension of a matrix
% for column vector M = ones(3,1)
% >> realdim(M)
% >> ans = 1
%
% for any other array shape it returns the same value as ndims

D = ndims(M);

if D == 2 && size(M,2) == 1
    D = 1;
end

end