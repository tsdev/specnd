function [CNT, Nsum] = histn(X, Y, varargin)
% function [count edges mid loc] = histcn(X, Y, edge1, edge2, ..., edgeN)
%
% Purpose: compute n-dimensional histogram
%
% INPUT
%   - X: is (M x N) array, represents M data points in R^N
%   - edgek: are the bin vectors on dimension k, k=1...N.
%     If it is a scalar (Nk), the bins will be the linear subdivision of
%     the data on the range [min(X(:,k)), max(X(:,k))] into Nk
%     sub-intervals
%     If it's empty, a default of 32 subdivions will be used
%
% OUTPUT
%   - count: n-dimensional array count of X on the bins, i.e.,
%         count(i1,i2,...,iN) = cardinal of X such that
%                  edge1(i1) <= X(:,i1) < edge1(i1)+1 and
%                       ...
%                  edgeN(iN) <= X(:,iN) < edgeN(iN)+1
%   - edges: (1 x N) cell, each provides the effective edges used in the
%     respective dimension
%   - mid: (1 x N) cell, provides the mid points of the cellpatch used in
%     the respective dimension
%   - loc: (M x N) array, index location of X in the bins. Points have out
%     of range coordinates will have zero at the corresponding dimension.
%
% DATA ACCUMULATE SYNTAX:
%   [ ... ] = histcn(..., 'AccumData', VAL);
%   where VAL is M x 1 array. Each VAL(k) corresponds to position X(k,:)
%   will be accumulated in the cell containing X. The accumulate result
%   is returned in COUNT.
%   NOTE: Calling without 'AccumData' is similar to having VAL = ones(M,1)
%
%   [ ... ] = histcn(..., 'AccumData', VAL, 'FUN', FUN);
%     applies the function FUN to each subset of elements of VAL.  FUN is
%     a function that accepts a column vector and returns
%     a numeric, logical, or char scalar, or a scalar cell.  A has the same class
%     as the values returned by FUN.  FUN is @SUM by default.  Specify FUN as []
%     for the default behavior.
%
% Usage examples:
%   M = 1e5;
%   N = 3;
%   X = randn(M,N);
%   [N edges mid loc] = histcn(X);
%   imagesc(mid{1:2},N(:,:,ceil(end/2)))
%
% % Compute the mean on rectangular patch from scattered data
%   DataSize = 1e5;
%   Lat = rand(1,DataSize)*180;
%   Lon = rand(1,DataSize)*360;
%   Data = randn(1,DataSize);
%   lat_edge = 0:1:180;
%   lon_edge = 0:1:360;
%   meanData = histcn([Lat(:) Lon(:)], lat_edge, lon_edge, 'AccumData', Data, 'Fun', @mean);
%
% See also: HIST, ACCUMARRAY
%
% Bruno Luong: <brunoluong@yahoo.com>
% Last update: 25/August/2011

if ~ismatrix(X)
    error('histcn:WrongInput','X requires to be an (M x N) array of M points in R^N');
end

edgeN = varargin;
N     = numel(edgeN);
binN  = cellfun(@(C)numel(C),edgeN);

if numel(binN)==1
    binN1 = [binN-1 1];
    binN  = [binN 1];
else
    binN1 = binN-1;
end

% determine bin indices instead of coordinate values and store in X to
% spare memory
for ii = 1:N
    X(:,ii) = floor(interp1(edgeN{ii},[1:(binN(ii)-1) binN(ii)-1],X(:,ii),'linear'));
end

% faster to sum all bad indices than remove all NaN indices
nanIdx = any(isnan(X),2);
% Y(nanIdx,:) = [];
% X(nanIdx,:) = [];
binN1(1) = binN(1);
X(nanIdx,:) = 1;
X(nanIdx,1) = binN1(1);

% possible to use 'fillval' option to make NaN the empty bins, but it is
% too slow, also to use @mean is slow
%CNT  = accumarray(X,Y,binN1,@mean,NaN);
CNT  = accumarray(X,Y,binN1);
Nsum = accumarray(X,Y*0+1,binN1);

% cut off the extra pix usign variable number of higher dimensions
% NEAT LITTLE TRICK
slabIdx = repmat({':'},1,ndims(CNT)-1);

CNT  = CNT(1:end-1,slabIdx{:});
Nsum = Nsum(1:end-1,slabIdx{:});

end