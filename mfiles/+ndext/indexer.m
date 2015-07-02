function C = indexer(ind,sel,dim)
% indexes arrays with dimensions selected by variable
%
% C = indexer(ind)
%
% Creates a cell from the elements of the ind vector (identical to num2cell
% function). The output cell can be used then to index an array. For
% example to select the element of the A array with indices [2,2,3]:
%       A = rand(3,4,5);
%       C = indexer([2,2,3]);
%       element = A(C{:});
%
% C = indexer(ind,sel,dim)
%
% This 


switch nargin
    case 1
        C(sel) = mat2cell(ind,ones(1,size(ind,1)),size(ind,2));
    case 3
        C  = repmat({':'},1,dim);
        C(sel) = mat2cell(ind,ones(1,size(ind,1)),size(ind,2));        
    otherwise
        C = {};
end

end