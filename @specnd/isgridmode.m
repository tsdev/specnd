function isgrid = isgridmode(D)
% determines whether D is in grid mode or not (event mode)
%
% isgrid = ISGRIDMODE(D)
%
%
% Input:
%
% D         Specnd object.
%
% Output:
%
% mode      scalar value:
%               false   event mode,
%               true    grid mode.
%

% matrix dimensions
nAxis1 = size(D.raw.datcnt.value);
nPoint = numel(D.raw.datcnt.value);

nAxis2 = zeros(1,numel(D.raw.axis.value));
for ii = 1:numel(D.raw.axis.value)
    nAxis2(ii) = numel(D.raw.axis.value{ii});
end

% event/grid mode
if numel(nAxis1) == 2 && nAxis1(1) == 1 && nAxis1(2) == nPoint && ...
        numel(D.raw.axis.value) > 1 && all((nAxis2-nPoint)==0)
    isgrid = false;
else
    isgrid = true;
end

end