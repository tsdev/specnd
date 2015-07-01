function D = load_dat(fDir,fName,varargin)
% load TOF spectrum from HDF5 file

bin = varargin(1:4);

dir0 = pwd;
cd(fDir);

% read data dimensions
par = h5info(fName,'/specnd/datcnt');
nQ  = par.Dataspace.Size(1);
nE  = par.Dataspace.Size(2);
% load grid position information
gridPos = h5read(fName,'/specnd/gridpos');
% add last position afte the end of the file
gridPos = [gridPos nQ*nE+1];
gridVal = h5read(fName,'/specnd/gridval');

EN      = h5read(fName,'/specnd/ebin');


% load the saved Q grid for fast data loading
grid0  = h5read(fName,'/specnd/qbin');
grid = cell(1,3);
nGridEdge = zeros(1,3);

for ii = 1:3
    grid{ii} = grid0(ii,~isnan(grid0(ii,:)));
    nGridEdge(ii) = numel(grid{ii});
end
grid{4} = EN;
nGridEdge(4) = numel(grid{4});

% determine the necessary data cubes to load
idxGrid = [ones(4,1) nGridEdge'-1];
for ii = 1:4
    idx = find(grid{ii}<=bin{ii}(1),1,'last');
    if ~isempty(idx)
        idxGrid(ii,1) = idx;
    end
    idx = find(grid{ii}>=bin{ii}(end),1,'first')-1;
    if ~isempty(idx)
        idxGrid(ii,2) = idx;
    end
end

% load the necessary data
vGrid = cell(1,4);
for ii = 1:4
    vGrid{ii} = idxGrid(ii,1):idxGrid(ii,2);
end

% create the grid list of data blocks to load
gGrid = cell(1,4);
[gGrid{:}] = ndgrid(vGrid{:});

listGrid = sub2ind(nGridEdge-1,gGrid{:});
% data start/end positions in the hdf file
selGrid = ismember(gridVal,listGrid);
startPos = gridPos(selGrid);
endPos   = gridPos([false selGrid])-1;
% remove empty blocks
rmIdx = startPos>endPos;
startPos(rmIdx) = [];
endPos(rmIdx)   = [];

% load  data
dat0 = zeros(sum(endPos-startPos+1),1);
err0 = zeros(sum(endPos-startPos+1),1);
EN0  = zeros(sum(endPos-startPos+1),1);
axi0 = zeros(3,sum(endPos-startPos+1));

runIdx = 1;

fprintf('Loading pixels...\n');


sw_status(0,1)
nPos = numel(startPos);

perc = 0;
for ii = 1:nPos
    
    [idxQ1,idxE1] = ind2sub([nQ nE],startPos(ii));
    [idxQ2,~] = ind2sub([nQ nE],endPos(ii));
    nDat = idxQ2-idxQ1+1;
    dat0(runIdx+(1:nDat)-1)   = double(h5read(fName,'/specnd/datcnt',[idxQ1 idxE1],[nDat 1]));
    err0(runIdx+(1:nDat)-1)   = double(h5read(fName,'/specnd/errmon',[idxQ1 idxE1],[nDat 1]));
    axi0(:,runIdx+(1:nDat)-1) = double(h5read(fName,'/specnd/axis',  [1 idxQ1 idxE1],[3 nDat 1]));
    EN0(runIdx+(1:nDat)-1)    = EN(idxE1);
    runIdx = runIdx + nDat;
    
    if floor(ii/nPos*100)>perc
        perc = floor(ii/nPos*100);
        sw_status(ii/nPos*100);
    end
end
% load all data
% dat0 = reshape(double(h5read(fName,'/specnd/datcnt',[1 1],[nQ nE])),[nQ*nE 1]);
% err0 = reshape(double(h5read(fName,'/specnd/errmon',[1 1],[nQ nE])),[nQ*nE 1]);
% axi0 = reshape(double(h5read(fName,'/specnd/axis',  [1 1 1],[3 nQ nE])),[3 nQ*nE]);
% EN0  = reshape(double(repmat(EN(1:end-1),[nQ 1])),[nQ*nE 1]);

sw_status(100,2);

% remove NaN data values
nanidx = isnan(dat0);
dat0(nanidx) = [];
EN0(nanidx) = [];
err0(nanidx) = [];
axi0(:,nanidx) = [];

fprintf('Pixels are loaded into memory!\n');
fprintf('Binning pixels...\n');
% bin data
D = specnd([axi0' EN0],dat0,err0);
D.bin(varargin{:});
fprintf('Binning ready!\n');
cd(dir0);

end