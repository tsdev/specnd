function num3 = num3decompress(num1)
% decompress a single double into 3 numbers with 5 useful digits
%
% num1  1xN dimension
%

% get the 3 scale of the numbers
M = num1(end+(-2:0));

num3 = repmat(num1(1:end-3),[1 3])

% add extra epsilon to squeeze 1 into 0.99999
M = M*(1+1e-5);
% normalize to the maximum number
num3 = round(bsxfun(@mrdivide,num3,M),5);
% keep only 5 digits

num1 = sum(bsxfun(@times,num3,[1 1e-5 1e-10]'),1);

num1(end+(1:3)) = M;

end