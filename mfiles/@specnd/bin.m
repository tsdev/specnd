function bin(D,varargin)
% bins/rebins/average data
%
% bin(D,V1,V2,...)
%
% Bins event mode data into a histogram mode data. Bins along every data
% dimension (ndim(D)) have to be given.
%
% bin(D,V1,V2,...,idx)
%
% Rebins histogram mode data, where new bins are provided along dimensions
% selected by idx vector.
%
% Each bin will take the average value of points thats coordinates are
% within the bin boundaries. The given bin vectors interpreted as bin
% boundary points by default. Empty bins are substituted by NaN value and
% error bars are calculated by the Gaussian error propagation rule.
%
% See also ndext.histn.

% D(:,:,V) or bin(D,V,3) Operation on the 3rd dimension using the V vector
% The binning method is determined by the global option ?binmethod? with
% values ?weight?,?sliding?,?center?, it can be temporarily overwritten
% using the same option: for example D(:,:,V,?binmethod?,?weight?) If V has
% 0 element: Just select the axis, useful when a function handle follows,
% see later If V has 1 element: In event mode bins the data using the
% selected method A/B/C In histogram mode rebins the data with the new bin
% size If V has 2 elements ? summation between the range The resulting
% singleton dimension can be removed from the data matrix using the
% squeeze() method (redefined Matlab? builtin) Identical command: sum(D,3)
% (redefined Matlab? builtin) If V has more than 2 elements
% binning/rebinning using the bin points in V How to decide whether the
% user gave boundary/center bins? Global option for the default bin and a
% string option ?bintype? to override it: ?bnd? or ?cen?, for example
% D(:,:,V,?bintype?,?bnd?) Multiple operations are possible at once:
% D(V1,[],V2) or bin(D,V1,V2,[1 3]) In event mode: The integration keeps
% only points within the given limits, no summation For binning a bin needs
% to be provided for every data dimensions:
% 	Dbinned = D(V1,V2,V3);
% In subscripted assignment the data matrix can be accessed using standard
% Matlab? indexing, for example: D(:,1,1) = linspace(0,1,100)

% find the first string option
optIdx = ndext.findoption(varargin{:});
% number of input variables withouth options
nVari = optIdx-1;

if ~ishistmode(D)
    % check that the bins are right
    if ndim(D)~=nVari
        error('specnd:bin:WrongInput','For event mode data, bins needed for each dimension!');
    end
    % bins
    bin = varargin;
    % create automatic bins where the step is given
    nBin = cellfun(@(C)numel(C),bin);
    lim  = [min(D.raw.axis.value{1},[],1); max(D.raw.axis.value{1},[],1)];
    
    for ii = 1:ndim(D)
        if nBin(ii) == 1
            varargin{ii} = lim(1,ii):bin{ii}:lim(2,ii);
            if varargin{ii}(end)<lim(2,ii)
                varargin{ii}(end+1) = varargin{ii}(end) + bin{ii};
            end
        end
    end
    
    % do the bin
    [Ysum,Nsum] = ndext.histn(D.raw.axis.value{1},...
        [D.raw.datcnt.value D.raw.errmon.value.^2],bin{:},'emptyval',[NaN 1]);
    % create the dimension selector
    selDim = repmat({':'},1,ndim(D));
    % take the average of the event values
    D.raw.datcnt.value = Ysum(selDim{:},1)./Nsum;
    D.raw.errmon.value = sqrt(Ysum(selDim{:},2))./Nsum;
    
    % define new axis values
    D.raw.axis.value = cellfun(@(C)(C(1:end-1)+C(2:end))'/2,bin(:)','UniformOutput',false);
    validate(D);
    
else
    % rebins the data
    % selects data dimensions to bin
    idx = varargin{nVari};
    % check that the bins are right
    if numel(idx)~=(nVari-1) || max(idx) > ndim(D)
        error('specnd:bin:WrongInput','Wrong number of input bins!');
    end
    
    % create new bins where only the bin width is given
    nBin = cellfun(@(C)numel(C),varargin(1:(nVari-1)));
    lim  = [cellfun(@(C)min(C),D.raw.axis.value); cellfun(@(C)max(C),D.raw.axis.value)];
    
    % cell storing the bins along each data dimension
    bin = cell(1,ndim(D));
    
    for ii = 1:ndim(D)
        if any(idx==ii)
            if nBin(idx==ii) == 1
                bin{ii} = (lim(1,idx(ii))-bin{ii}/2):bin{ii}:(lim(2,idx(ii))+bin{ii}/2);
            else
                bin(ii) = varargin(idx==ii);
            end
        else
            bin(ii) = D.raw.axis.value(ii);
            % create edge bins from center bins
            bin = [(3*bin(1)-bin(2))/2 (bin(1:(end-1))+bin(2:end))/2 (3*bin(end)-bin(end-1))/2];
            
        end
        bin{ii} = bin{ii}(:);
    end
    
    % create the full grid
    X = cell(1,ndim(D));
    [X{:}] = ndgrid(D.raw.axis.value{:});
    % create the column list of coordinates
    X = reshape(cell2mat(permute(X,[1 3 2])),[],ndim(D));
    
    % bin the data
    [Ysum,Nsum] = ndext.histn(X,[D.raw.datcnt.value(:) ...
        D.raw.errmon.value(:).^2],bin{:},'emptyval',[NaN 1]);
    % create the dimension selector
    selDim = repmat({':'},1,ndim(D));
    % take the average of the event values and calculate error
    D.raw.datcnt.value = Ysum(selDim{:},1)./Nsum;
    D.raw.errmon.value = sqrt(Ysum(selDim{:},2))./Nsum;
    
    % define new axis values
    D.raw.axis.value = cellfun(@(C)(C(1:end-1)+C(2:end))/2,bin(:),'UniformOutput',false);
    validate(D);
    
end

end