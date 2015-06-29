function [CNT, Nsum] = histn(X, Y, varargin)
% calculates histogram of arbitrary dimensional data
%
% function [CNT, Nsum] = histcn(X,Y,bin1,bin2,...)
%
% Input:
%
% X         Array with size of [nPoint nDim], that represents
%           positions in the nDim dimensional space.
% Y         Column vector with nPoint element, that represents values at
%           the points defined in X. {X,Y} defines a scalar field in the
%           nDim dimensional space.
% binI      Row vectors that define bin edges along the I-th dimension.
%           I goes from 1 to nDim. Each vector has to have at least two
%           elements. The number of bins along the I-th dimension is equal
%           to the number of elements in the binI vector minus one. Thus:
%               nBinI = numel(binI)-1
%
% Output:
%
% CNT       Array with size of [nBin1 nBin2 nBin3 ...]. Each pixel contains
%           the sum of the elements of Y that are within the selected bin:
%               bin1(i1) <= X(:,i1) < bin1(i1)+1 and
%               	...
%               binN(iN) <= X(:,iN) < binN(iN)+1
%           Points of X, that are outside of the bin boundaries are
%           omitted. Empty pixels will contain NaN.
% Nsum      Array with the same size as CNT, contains the number points
%           that are contributing to the sum. Only calculated if two output
%           is expected. Empty pixels will contain the value 1, this way
%           the average of each pixel can be calculated quickly, dividing
%           CNT with Nsum.
%
% Example:
%
% Random points in 2D.
%
% nPoint = 1e3;
% nDim   = 2;
% bin = linspace(0,1,101);
%
% X = rand(nPoint,nDim);
% Y = sin(X(:,1)*2*pi);
% [CNT,Nsum] = ndext.histn(X,Y,bin,bin);
% figure
% imagesc(CNT./Nsum);
%
%
% Create points on a square lattice.
%
% [xx,yy] = ndgrid(1:0.5:10,1:0.5:10);
%
% bin = linspace(0,11,101);
%
% [CNT,Nsum] = ndext.histn([xx(:) yy(:)],sin(xx(:)),bin,bin);
% figure
% imagesc(CNT./Nsum);
%
% Oversample the sine function defined on a finite point.
% xx = 0:0.5:10;
% bin = linspace(0,11,101);
%
% CNT = ndext.histn([xx(:)],sin(xx(:)),bin);
% figure
% plot(CNT,'o-');
%

if ~ismatrix(X)
    error('histn:WrongInput','X requires to be an (nPoint x nDim) array of nPoint points in R^nDim space.');
end

bin  = varargin;
N    = numel(bin);
nBin = cellfun(@(C)numel(C),bin);

if any(nBin<2)
    error('histn:WrongInput','All bin edge vector has to have at least two elements.')
end

if numel(nBin)==1
    nBin1 = [nBin-1 1];
    nBin  = [nBin 1];
else
    nBin1 = nBin-1;
end

% determine bin indices instead of coordinate values and store in X to
% spare memory
for ii = 1:N
    X(:,ii) = floor(interp1(bin{ii},[1:(nBin(ii)-1) nBin(ii)-1],X(:,ii),'linear'));
end

% faster to sum all bad indices than remove all NaN indices
nanIdx = any(isnan(X),2);
% Y(nanIdx,:) = [];
% X(nanIdx,:) = [];
nBin1(1) = nBin(1);
X(nanIdx,:) = 1;
X(nanIdx,1) = nBin1(1);

% possible to use 'fillval' option to make NaN the empty bins, but it is
% too slow, also to use @mean is slow
%CNT  = accumarray(X,Y,binN1,@mean,NaN);
CNT  = accumarray(X,Y,nBin1,[],NaN);

% cut off the extra pix usign variable number of higher dimensions
% NEAT LITTLE TRICK
slabIdx = repmat({':'},1,ndims(CNT)-1);

CNT  = CNT(1:end-1,slabIdx{:});

if nargout>1
    Nsum = accumarray(X,Y*0+1,nBin1,[],1);
    Nsum = Nsum(1:end-1,slabIdx{:});
end

end