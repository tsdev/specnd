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

% user name, etc
dat.param.name{1} = 'Inst';
dat.param.name{2} = 'User';
dat.param.name{3} = 'L.C.';
dat.param.name{4} = 'Date Time';

dat.param.value{1} = lines(6,1:4);
dat.param.value{2} = lines(6,5:10);
dat.param.value{3} = lines(6,11:14);
% time format: % 10-Jul-15 16:08:37
dat.param.value{4} = datetime(lines(6,15:32),'InputFormat','dd-MMM-yy HH:mm:ss');

dat.param.name{5} = 'Title';
dat.param.value{5} = strtrim(lines(10,:));

names = lines(13:16,:)';
names = strsplit(names(:)',' ');
values = lines(17:20,:)';
values = sscanf(values(:)','%f',[1 inf]);

dat.param.name(end+(1:numel(names)))  = names;
dat.param.value(end+(1:numel(names))) = num2cell(values);

names = lines(23:32,:)';
names = strtrim(mat2cell(names(:)',1,16*ones(1,50)));

dat.param.name(end+(1:numel(names))) = names;

values = lines(33:42,:)';
values = sscanf(values(:)','%f');
dat.param.value(end+(1:numel(names))) = num2cell(values);

% find the first frame position
fIdx = [find(all(bsxfun(@minus,lines(:,1:3),'SSS')==0,2))' size(lines,1)+1];
% frame length
fLength = diff(fIdx(1:2));
% number of Frames
nFrame = numel(fIdx)-1;
% read count positions
cIdx = find(all(bsxfun(@minus,lines(fIdx(1):end,1:3),'III')==0,2),1,'first');
if isempty(cIdx)
    cIdx = find(all(bsxfun(@minus,lines(fIdx(1):end,1:3),'FFF')==0,2),1,'first');
end
% number of data lines
dLength = fLength-cIdx-1;
fIdx = fIdx(1);
% data dimensions stored in file
nPix = sscanf(lines(fIdx(1)+cIdx,:),'%f');
% number of data columns
dCol = ceil(nPix/dLength);
% number of NaNs to insert
nNan = dCol - mod(nPix,dCol);

dat.datcnt.value = zeros(sqrt(nPix),sqrt(nPix),nFrame);
dat.datcnt.name  = {'intensity'};
dat.datcnt.label = {'neutron scattering intensity'};
% read data
for ii = 1:nFrame
    rIdx   = fIdx+cIdx+(ii-1)*fLength+(1:dLength);
    dLines = lines(rIdx,:)';
    dTemp  = [sscanf(dLines(:)','%d'); nan(nNan,1)];
    dTemp  = reshape(dTemp,dCol,[]);
    dat.datcnt.value(:,:,ii) = reshape(dTemp(1:nPix),[sqrt(nPix) sqrt(nPix)]);
end

% number of values per frame
nVal = sscanf(lines(fIdx+3,:),'%d'); nVal = nVal(1);
nVal = 5;
% read monitor values
% TODO
rIdx   = fIdx+cIdx+((1:nFrame)-1)*fLength-3;
mLines = lines(rIdx,:)';
mTemp  = sscanf(mLines(:)','%f');

dat.errmon.value = repmat(permute(mTemp(2:nVal:end),[2 3 1]),[sqrt(nPix) sqrt(nPix) 1]);
dat.errmon.label = 'MON';
dat.errmon.name  = 'monitor';

% axis values
dat.axis.value{1} = (1:sqrt(nPix))';
dat.axis.name{1}  = 'x-axis';
dat.axis.label{1} = 'pixel index';
dat.axis.value{2} = (1:sqrt(nPix))';
dat.axis.name{2}  = 'y-axis';
dat.axis.label{2} = 'pixel index';
% read omega angle values
dat.axis.value{3} = mTemp(4:nVal:end)/1e3;
dat.axis.name{3}  = 'omega [deg]';
dat.axis.label{3} = 'sample rotation angle';


% add additional fiels
dat.param.label = cell(1,86);
dat.channel.value = ones(1,1);
dat.channel.name  = 'ch1';
dat.channel.label = 'ch1';
dat.log = struct;
dat.fit = struct;
dat.g.value = eye(3);
dat.g.name  = '';
dat.g.label = '';

% one more necessary field
dat.param.name{end+1}  = 'fid';
dat.param.label{end+1} = 'file identifier for text output';
dat.param.value{end+1} = 1;

dat = specnd(dat);

end