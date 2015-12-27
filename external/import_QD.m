function [dat, headerOut] = import_QD(datFile,xStr,yStr,eStr)
% import Quantum Design data

fid = fopen(datFile);

lines = textscan(fid,'%s','Delimiter','\n','whitespace','');
lines = lines{1};
fclose (fid);

dLine  = find(strcmp(lines,'[Data]'));
header = strsplit(lines{dLine+1},',')';

datI   = importdata(datFile,',',dLine+1);
header = header(1:size(datI.data,2));

% empty columns
eCol = sum(isnan(datI.data),1)==size(datI.data,1);
datI.data = datI.data(:,~eCol);
header = header(~eCol);

if nargout>1
    headerOut = header;
end

if nargin == 1
    dat = struct;
    return
end

dat.x = datI.data(:,strcmp(header,xStr));
dat.y = datI.data(:,strcmp(header,yStr));
if nargin>3
    dat.e = datI.data(:,strcmp(header,eStr));
else
    dat.e = dat.y*0;
end

dat.datafile = datFile;
dat.x_label  = xStr;
dat.y_label  = yStr;

dat = spec1d(dat);

end