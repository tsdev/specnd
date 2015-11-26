function dat = import_D20(fName)
% import raw data files from D20 at ILL

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

dat.par(1).value = strtrim(lines(6,1:4));
dat.par(2).value = lines(6,5:10);
dat.par(3).value = lines(6,11:14);
% time format: % 10-Jul-15 16:08:37
dat.par(4).value = datetime(lines(6,15:32),'InputFormat','dd-MMM-yy HH:mm:ss');

dat.par(5).name = 'Sample';
dat.par(5).value = strtrim(lines(9,21:end));
dat.par(6).name = 'Proposal Number';
dat.par(6).value = strtrim(lines(11,21:end));
dat.par(7).name = 'Experimental Title';
dat.par(7).value = strtrim(lines(12,21:end));

dat.par(8).name = 'Start Time';
dat.par(8).value = datetime(lines(14,21:38),'InputFormat','dd-MMM-yy HH:mm:ss');
dat.par(9).name = 'End Time';
dat.par(9).value = datetime(lines(14,58:end),'InputFormat','dd-MMM-yy HH:mm:ss');

names = lines([18:23 33:37 46:51 61:64 72:82 97:102],:)';
names = reshape(names(:)',16,[])';
values = lines([24:29 38:42 52:57 65:68 83:93 103:108],:)';
values = sscanf(values(:)','%f',[1 inf]);

% convert names into cell of strings
names  = strtrim(mat2cell(names,ones(190,1),16));
values = num2cell(values);

% remove spare fields
spIdx = strcmp(names,'(spare)');
names = names(~spIdx);
values = values(~spIdx);

[dat.par(end+(1:numel(names))).name] = names{:};
[dat.par(end-(numel(names):-1:1)+1).value] = values{:};

% numor
numor = sscanf(lines(110,:),'%f %f %f %f');
numor = numor(4);

dat.par(end+1).name  = 'numor';
dat.par(end+1).value = numor;

datStr = lines(113:end,:)';

dat.sig.value = sscanf(datStr(:),'%d');
dat.sig.name  = 'det';
dat.sig.label = 'Detector Counts';

% get monitor
dat.mon.value = dat.par(strcmp({dat.par(:).name},'MonitorCnts')).value;
dat.mon.name = 'MonitorCnts';
dat.mon.label = 'MonitorCnts';

% axis values
dat.ax(1).value = dat.par(strcmp({dat.par(:).name},'2theta')).value + 3.2 + (0:0.05:159.95)';
dat.ax(1).name  = '2theta';
dat.ax(1).label = '2theta';

% add additional fields
dat.g.value = 1;
dat.g.name  = '';
dat.g.label = '';

end