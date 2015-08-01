function dat = import_D10(fName)
% import raw data files from D10 at ILL

dat = struct;
% open file
fid = fopen(fName);
% scan full file into a cell
lines = textscan(fid,'%s','Delimiter','\n','whitespace','');
% convert files into an nLines x 80 character matrix
lines = cell2mat(lines{1});
fclose(fid);

dat.par = struct('value',{},'name',{},'label',{});
% user name, etc
dat.par(1,1).name = 'Inst';
dat.par(2,1).name = 'User';
dat.par(3).name = 'L.C.';
dat.par(4).name = 'Date Time';

dat.par(1).value = lines(6,1:4);
dat.par(2).value = lines(6,5:10);
dat.par(3).value = lines(6,11:14);
% time format: % 10-Jul-15 16:08:37
dat.par(4).value = datetime(lines(6,15:32),'InputFormat','dd-MMM-yy HH:mm:ss');

dat.par(5).name = 'Title';
dat.par(5).value = strtrim(lines(10,:));

names = lines(13:16,:)';
names = strsplit(names(:)',' ');
values = lines(17:20,:)';
values = sscanf(values(:)','%f',[1 inf]);

% extract icdesc as a vector from the last 7 parameters
icdesc = values((-6:0)+end);
names  = [names(1:(end-7)) 'icdesc'];
values = [num2cell(values(1:(end-7))) icdesc];

% internally the temperature is 23 instead of -1
icdesc(icdesc==-1) = 23;
icdesc(icdesc==0) = [];

[dat.par(end+(1:numel(names))).name]  = names{:};
[dat.par(end-(numel(names):-1:1)+1).value] = values{:};

names = lines(23:32,:)';
names = strtrim(mat2cell(names(:)',1,16*ones(1,50)));
values = lines(33:42,:)';
values = num2cell(sscanf(values(:)','%f')');

% extract ub matrix
ubIdx = ~cellfun(@(C)isempty(C),strfind(names,'ub'));
ubMat = reshape([values{ubIdx}],[3 3])';

names(ubIdx) = [];
names(end+1) = {'ub'};

values(ubIdx) = [];
values(end+1) = {ubMat};

% remove spare fields
spIdx = strcmp(names,'(spare)');
names = names(~spIdx);
values = values(~spIdx);

[dat.par(end+(1:numel(names))).name] = names{:};
[dat.par(end-(numel(names):-1:1)+1).value] = values{:};

% find the first frame position
fIdx = [find(all(bsxfun(@minus,lines(:,1:3),'SSS')==0,2))' size(lines,1)+1];
% frame length
fLength = diff(fIdx(1:2));
% number of Frames
nFrame = numel(fIdx)-1;

% number of scan points, actual number of points can be less, if the scan
% is not finished
nkmes = dat.par(strcmp({dat.par.name},'nkmes')).value;
% number of detector pixels
nPix   = dat.par(strcmp({dat.par.name},'nb_det')).value;
% detector dimension
nEdge  = sqrt(nPix);
% number of angles (number of parameters stored per data point
%nbang  = dat.par(strcmp({dat.par.name},'nbang')).value;
% scanned variable
manip  = dat.par(strcmp({dat.par.name},'manip')).value;


% predefined variable names that are stored for each point
vName  = mat2cell('tha3chphtaoasaatwmcmt1t2reticanumucnglgunvnhttcomntmqhqkql',...
    1,2*ones(1,29));
vLabel = {'2theta','omega','chi','phi','2the_ana','ana-omeg','SamplTab',...
    'analyser','Womeg_mo','cha_mono','mono_t1','mono_t2','mono_ren',...
    'monotilt','curvanal','nu','flatcone','canne','Tilt_chi','Tilt_phi',...
    'nez-vert','nez-hori','Temperature [K]','Count','Monitor',...
    'Time [ms]','QH [rlu]','QK [rlu]','QL [rlu]'};

% different data type depending on the scan type (kctrl value)
switch dat.par(strcmp({dat.par.name},'kctrl')).value
    % TODO Q scan with the multidetector
    case 0 % omega scan without multidetector
        % read in the saved numbers
        rIdx   = (fIdx(1)+4):(fIdx(2)-1);
        dLines = lines(rIdx,:)';
        dTemp  = sscanf(dLines(:)','%f');
        
        % add count, monitor and time header indices
        icdesc = [24:26 icdesc];
        
        nCol = numel(icdesc);
        addI = ceil(numel(dTemp)/nCol)*nCol-numel(dTemp);
        dTemp(end+(1:addI)) = nan;
        
        dTemp = reshape(dTemp,nCol,[])';
                
        dat.sig.value = dTemp;
        [dat.ch(1:nCol,1).name] = vName{icdesc};
        [dat.ch(1:nCol).label]  = vLabel{icdesc};
        [dat.ch(1:nCol).value]  = ndext.list(1:(nCol+3));
        
        dat.sig.name  = '';
        dat.sig.label = '';
                
    case 7 % Q scan without multidetector
        % read in the saved numbers
        rIdx   = (fIdx(1)+4):(fIdx(2)-1);
        dLines = lines(rIdx,:)';
        dTemp  = sscanf(dLines(:)','%f');
        
        % add count, monitor and time header indices
        icdesc = [24:26 icdesc];
        
        nCol = numel(icdesc);
        addI = ceil(numel(dTemp)/nCol)*nCol-numel(dTemp);
        dTemp(end+(1:addI)) = nan;
        
        dTemp = reshape(dTemp,nCol,[])';
        
        % starting and final hklE values
        qLim = {'qH','qK','qL' 'Hmax','Kmax','Lmax'};
        % step size in hklE
        %qStep = {'DeltaH','DeltaK','DeltaL','Deltaenergy'};
        vqLim = zeros(1,6);
        for ii = 1:6
            vqLim(ii) = dat.par(strcmp({dat.par.name},qLim{ii})).value;
        end
        % create q-scan
        qPoint = sw_qscan({vqLim(1:3) vqLim(4:6) nkmes})';
        % add the q-label to the list of header
        icdesc = [27:29 icdesc];
        
        dat.sig.value = [qPoint(1:size(dTemp,1),:) dTemp];
        [dat.ch(1:(nCol+3),1).name]  = vName{icdesc};
        [dat.ch(1:(nCol+3)).label] = vLabel{icdesc};
        [dat.ch(1:(nCol+3)).value] = ndext.list(1:(nCol+3));
        
        dat.sig.name  = '';
        dat.sig.label = '';
        
    case 4 % omega scan with multidetector
        % add time, monitor and count header indices
        icdesc = [26 25 24 icdesc];

        % read count positions
        cIdx = find(all(bsxfun(@minus,lines(fIdx(1):end,1:3),'III')==0,2),1,'first');
        if isempty(cIdx)
            cIdx = find(all(bsxfun(@minus,lines(fIdx(1):end,1:3),'FFF')==0,2),1,'first');
        end
        % number of data lines
        dLength = fLength-cIdx-1;
        fIdx = fIdx(1);
        % number of data columns
        dCol = ceil(nPix/dLength);
        % number of NaNs to insert
        nNan = dCol - mod(nPix,dCol);
        
        dat.sig.value = zeros(sqrt(nPix),sqrt(nPix),nFrame);
        dat.sig.name  = vName{24};
        dat.sig.label = vLabel{24};
        % read data
        for ii = 1:nFrame
            rIdx   = fIdx+cIdx+(ii-1)*fLength+(1:dLength);
            dLines = lines(rIdx,:)';
            dTemp  = [sscanf(dLines(:)','%d'); nan(nNan,1)];
            dTemp  = reshape(dTemp,dCol,[]);
            dat.datcnt.value(:,:,ii) = reshape(dTemp(1:nPix),[nEdge nEdge]);
        end
        
        % number of values stored per frame
        nVal = numel(icdesc);
        % read monitor values
        % TODO
        rIdx   = fIdx+cIdx+((1:nFrame)-1)*fLength-2;
        mLines = lines(rIdx,:)';
        mTemp  = sscanf(mLines(:)','%f');
        
        if all(mTemp(2:nVal:end)==mTemp(2))
            dat.mon.value = mTemp(2);
        else
            dat.mon.value = repmat(permute(mTemp(2:nVal:end),[2 3 1]),[nEdge nEdge 1]);
        end
        dat.mon.label = vName{25};
        dat.mon.name  = vLabel{25};
        
        % axis values
        dat.ax(1).value = (1:nEdge)';
        dat.ax(1).name  = 'xa';
        dat.ax(1).label = 'pixel index [#]';
        dat.ax(2,1).value = (1:nEdge)';
        dat.ax(2).name  = 'ya';
        dat.ax(2).label = 'pixel index [#]';
        % read the values of the manipulated variable, assuming it is the
        % first that is saved
        dat.ax(3).value = mTemp(4:nVal:end)/1e3;
        dat.ax(3).name  = vName{manip};
        dat.ax(3).label = vLabel{manip};
        
        % take care of the single channel
        dat.ch.value = 1;
        dat.ch.name  = 'ch1';
        dat.ch.label = 'channel 1';
        
    otherwise
        error('import_D10:UnknownDataType','Unknown data collection mode!')
end

% add additional fields
dat.par(1).label = '';
dat.g.value = 1;
dat.g.name  = '';
dat.g.label = '';

end