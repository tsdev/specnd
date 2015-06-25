function num1 = num3compress(num3)
% compress 3 numbers with 5 useful digit into a single number with double
% precision
%
% num3  3xN dimension
%

% get the 3 scale of the numbers
M = max(num3,[],2);
% add extra epsilon to squeeze 1 into 0.99999
M = M*(1-1e-5);
num1 = sum(bsxfun(@times,int64(bsxfun(@times,num3,M*1e5)),int64([1 2^16 2^32]')),1);

end