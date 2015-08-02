function ishist = ishistmode(D)
% determines whether D is in histogram mode or not (event mode)
%
% ishist = ISHISTMODE(D)
%
%
% Input:
%
% D         Specnd object.
%
% Output:
%
% mode      scalar value:
%               false   data is in event mode, storing coordinates for each
%                       point,
%               true    histogram mode (data is binned).
%

nAxis = naxis(D);

% empty objects are in histogram mode
if ndim(D) == 0
    ishist = true;
    return
end

nSig  = size(D.raw.sig.val);
nSig  = [nSig ones(1,numel(nAxis)-numel(nSig))];

if numel(D.raw.ax)>1 && any(nSig~=nAxis)
    ishist = false;
else
    ishist = true;
end

end