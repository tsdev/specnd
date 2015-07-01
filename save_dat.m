function save_dat(fDir,fList,outName,nBin,cFact)
% save and sort TOF spectrum into an HDF5 file

% number of bin edges
nBinEdge = nBin + 1;

fprintf('Preparing the necessary parameters for loading the .nxspe files!\n')
% variable location in the HDF5 file
dataPath = '/data/data/';
infoPath = '/data/NXSPE_info/';

% check phi angles
nFile = numel(fList);

psi = zeros(1,nFile);
T   = zeros(1,nFile);

% read out info from the file name
% temperature, sample roation angle
for ii = 1:nFile
    [~,tName] = fileparts(fList(ii).name);
    temp      = sscanf(strrep(strrep(tName(13:end),'p','.'),'_',' '),'%f %f %f');
    T(ii)     = temp(2);
    psi(ii)   = temp(3)*pi/180;
end

% sort files according to sample rotation angle
[psi,sIdx] = sort(psi);
fList      = fList(sIdx);

% read files
% assumnig all files have the same energy bin
% incident energy can be different for the different files

det_az = h5read([fDir fList(1).name],[dataPath 'azimuthal'])*pi/180;
det_po = h5read([fDir fList(1).name],[dataPath 'polar'])*pi/180;

% boundary bin EN
EN = h5read([fDir fList(1).name],[dataPath 'energy'])';
% center bin EN
ENc = (EN(1:end-1)+EN(2:end))/2;

Ei = h5read([fDir fList(1).name],[infoPath 'fixed_energy']);
ki = sw_converter(Ei,'meV','A-1');
meV2A1 = 1/sw_converter(1,'A-1','meV');
KF = sqrt(ki^2 - meV2A1*ENc);

nE   = numel(ENc);
nPix = numel(det_az);
nPsi = nFile;
nQ   = nPix*nPsi;

% load all data into memory and save it into a new file but sorted according to energy bin
% can be too much to keep in RAM

% Q grid for the detectors
temp1 = sin(det_po);
Q        = zeros(3,nPix,nE,'single');
Q(1,:,:) = (temp1.*cos(det_az))*KF;
Q(2,:,:) = (temp1.*sin(det_az))*KF;
Q(3,:,:) = ki-cos(det_po)*KF;
%E        = ones(nPix,1)*ENc;


dir0 = pwd;
cd(fDir);
h5create(outName,'/specnd/datcnt',[nQ nE],   'Datatype','single','ChunkSize',[floor(nPix*cFact) 1]);
h5create(outName,'/specnd/errmon',[nQ nE],   'Datatype','single','ChunkSize',[floor(nPix*cFact) 1]);
h5create(outName,'/specnd/axis',  [3 nQ nE], 'Datatype','single','ChunkSize',[3 floor(nPix*cFact) 1]);
h5create(outName,'/specnd/ebin',[1 nE+1],'Datatype','double');
h5create(outName,'/specnd/qbin',[3 max(nBinEdge)],'Datatype','double','FillValue',NaN);

% Q limits
Qlim = zeros(3,2);
Qrot = zeros(size(Q),'single');

fprintf('Loading .nxspe files...\n')
sw_status(0,1)

for ii = 1:nPsi

    dat = single(h5read([fDir fList(ii).name],[dataPath 'data']));
    err = single(h5read([fDir fList(ii).name],[dataPath 'error']));
    
    h5write(outName,'/specnd/datcnt',dat',[1+(ii-1)*nPix 1],[nPix nE]);
    h5write(outName,'/specnd/errmon',err',[1+(ii-1)*nPix 1],[nPix nE]);
    
    % rotate Q of the sample
    [~,R] = sw_rot([0 1 0],psi(ii));
    %Qrot = mmat(R,Q);
    % speed it up
    
    for jj = 1:3
        Qrot(jj,:,:) = sum(bsxfun(@times,R(jj,:)',Q),1);
    end
    
    % check Q limits
    for jj = 1:3
        limi = [min(Qrot(jj,:)) max(Qrot(jj,:))];
        if limi(1)<Qlim(jj,1)
            Qlim(jj,1) = limi(1);
        end
        if limi(2)>Qlim(jj,2)
            Qlim(jj,2) = limi(2);
        end
    end
    
    h5write(outName,'/specnd/axis',Qrot,[1 1+(ii-1)*nPix 1],[3 nPix nE]);
    
    sw_status(ii/nPsi*100)
end
sw_status(100,2)
fprintf('The .nxspe files are loaded and saved into an hdf5 file.\n')

% make rough bin on the data, storing bin edges
bin = cell(1,3);
for ii = 1:3
    bin{ii}      = linspace(Qlim(ii,1),Qlim(ii,2),nBinEdge(ii));
    bin{ii}(end) = bin{ii}(end) + 10*eps('single');
end

fprintf('Sorting the pixels in the hdf5 file...\n')

gridPos = zeros(1,0);
gridVal = zeros(1,0);

sw_status(0,1)
for ii = 1:nE
    dat  = h5read(outName,'/specnd/datcnt',[1 ii],[nQ 1]);
    err  = h5read(outName,'/specnd/errmon',[1 ii],[nQ 1]);
    axis = h5read(outName,'/specnd/axis',  [1 1 ii],[3 nQ 1]);
    
    % use interp to get bin indices
    bAxis = zeros(size(axis));
    for jj = 1:3
        bAxis(jj,:,:) = floor(interp1(bin{jj},[1:nBin(jj) nBin(jj)],axis(jj,:,:),'linear'));
    end
    
    % sort bins
    [sBin,idx] = sort(sub2ind(nBin,bAxis(1,:),bAxis(2,:),bAxis(3,:)));
    % list of start position non empty bins
    gridPos0 = [1 find(diff(sBin)>0)+1];
    % correponding bin index for each starting position
    gridVal0 = sBin(gridPos0);
    % save the bin positions, empty bins represented with an index 0
    %binPos(binVal+(ii-1)*size(binPos,1)) = binPosE + (ii-1)*nPix*nPsi;
    
    gridPos = [gridPos gridPos0 + (ii-1)*nPix*nPsi]; %#ok<AGROW>
    gridVal = [gridVal gridVal0+(ii-1)*prod(nBin)]; %#ok<AGROW>
    
    h5write(outName,'/specnd/datcnt',dat(idx),[1 ii],[nQ 1]);
    h5write(outName,'/specnd/errmon',err(idx),[1 ii],[nQ 1]);
    h5write(outName,'/specnd/axis',axis(:,idx),[1 1 ii],[3 nQ 1]);
    sw_status(ii/nE*100)
end

h5create(outName,'/specnd/gridpos',size(gridPos),'Datatype','double');
h5write(outName,'/specnd/gridpos',gridPos,[1 1],size(gridPos));
h5create(outName,'/specnd/gridval',size(gridVal),'Datatype','double');
h5write(outName,'/specnd/gridval',gridVal,[1 1],size(gridVal));


h5write(outName,'/specnd/ebin',EN,[1 1],[1 nE+1]);

for ii = 1:3
    h5write(outName,'/specnd/qbin',bin{ii},[ii 1],[1 numel(bin{ii})]);
end
sw_status(100,2)

cd(dir0);

fprintf('All data files are sorted and saved to %s.\n',[fDir outName])

end