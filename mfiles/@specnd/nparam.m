function nParam = nparam(D)
% number of parameters stored in specnd object

subField  = {'value' 'name' 'label'};

for ii = 1:numel(subField)
    
    nTemp = size(D.raw.param.(subField{ii}));
    
    if ~iscell(D.raw.param.(subField{ii})) || numel(nTemp)>2 || nTemp(1)~=1
        error('specnd:WrongParam','Parameter dimensions are wrong!');
    end
    
end

nParam = nTemp(2);

end