function varargout = list(x)
% return matrix elements as separate output arguments
% example: [a1,a2,a3,a4] = list(1:4)

varargout = num2cell(x);

end