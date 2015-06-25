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

if size(D.raw.axis.value{1},2) > 1
    ishist = false;
else
    ishist = true;
end

end