function obj = bin(obj,varargin)
% bins/rebins/integrate data
%
% D(:,:,V) or bin(D,V,3) Operation on the 3rd dimension using the V vector
% The binning method is determined by the global option ?binmethod? with
% values ?weight?,?sliding?,?center?, it can be temporarily overwritten
% using the same option: for example D(:,:,V,?binmethod?,?weight?) If V has
% 0 element: Just select the axis, useful when a function handle follows,
% see later If V has 1 element: In event mode bins the data using the
% selected method A/B/C In histogram mode rebins the data with the new bin
% size If V has 2 elements ? summation between the range The resulting
% singleton dimension can be removed from the data matrix using the
% squeeze() method (redefined Matlab® builtin) Identical command: sum(D,3)
% (redefined Matlab® builtin) If V has more than 2 elements
% binning/rebinning using the bin points in V How to decide whether the
% user gave boundary/center bins? Global option for the default bin and a
% string option ?bintype? to override it: ?bnd? or ?cen?, for example
% D(:,:,V,?bintype?,?bnd?) Multiple operations are possible at once:
% D(V1,[],V2) or bin(D,V1,V2,[1 3]) In event mode: The integration keeps
% only points within the given limits, no summation For binning a bin needs
% to be provided for every data dimensions:
% 	Dbinned = D(V1,V2,V3);
% In subscripted assignment the data matrix can be accessed using standard
% Matlab® indexing, for example: D(:,1,1) = linspace(0,1,100)

% find the first string option
[val,opt] = nd.findoption(varargin);

if obj


end