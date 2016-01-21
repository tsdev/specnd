function dat = import_DMC(fName, importp, norm)
% function to import DMC data
%
% dat = IMPORT_DMC(fName, {importP})
%
% Input:
%
% fName     String, file name.
% importP   If true, all parameters will be imported into a sruct, default
%           values is true.
%
% Output:
%
% dat       Struct with fields (x,y,e).
%


if nargin < 2
    importp = true;
end

% import the data
raw    = importdata(fName,' ',3);
header = raw.textdata;

h2 = strsplit(header{2},', ');
h3 = strsplit(header{3},', ');

if importp
    % read the bottom part of the file
    % Why would somebody put header lines into the bottom of the data file???
    
    % save parameters
    param = struct('name',{},'val',{},'label',{});
    
    % read parameters from header
    param(end+1).name = 'title';
    param(end).val  = header{1};
    param(end).label  = '';
    
    h2(end+[0 1]) = [h3(end) h2(end)];
    
    for ii = 1:(numel(h2)-1)
        hh = strtrim(strsplit(h2{ii},'='));
        param(end+1).name = hh{1}; %#ok<AGROW>
        hnum = str2double(hh{2});
        if isnan(hnum)
            param(end).val  = hh{2}(2:(end-1));
        else
            param(end).val  = hnum;
        end
        param(end).label  = '';
    end
    % date time
    hh = strtrim(strsplit(h2{end},'='));
    param(end+1).name = hh{1};
    param(end).val  = datestr(hh{2});
    param(end).label  = '';
    
    % read parameters from footer
    fid = fopen(fName);
    for ii = 1:83
        fgetl(fid);
    end
    
    line1 = strtrim(strsplit(fgetl(fid),'='));
    
    
    param(end+1).name = line1{1};
    param(end).val  = line1{2}(2:(end-1));
    param(end).label  = '';
    
    %for jj = 1:5
    while ~feof(fid)
        line1 = fgetl(fid);
        line1(line1=='''') = [];
        line1 = strtrim(strsplit(line1,'; '));
        
        for ii = 1:numel(line1)
            line2 = strsplit(line1{ii},'=');
            param(end+1).name = line2{1}; %#ok<AGROW>
            line3 = str2double(line2{2});
            if isnan(line3)
                param(end).val  = line2{2};
            else
                param(end).val  = line3;
            end
            param(end).label  = '';
            
        end
    end
    
    fclose(fid);
else
    param = struct;
end

% x-coordinates
xval = sscanf(h3{1},'%f')';

dat.x = (xval(1):xval(2):xval(3))';
dat.y = reshape(raw.data(1:40,:)',[],1);
dat.e = reshape(raw.data(41:80,:)',[],1);

dat.par = param;

end