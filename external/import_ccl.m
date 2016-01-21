function dat = import_ccl(fName, mon0)
% imports reflection list from TRICS .ccl file
%
% dat = IMPORT_CCL(fName,mon)
%
% Input:
%
% fName     String, the name of the .ccl file.
% mon       Monitor value, default is 1000.
%
% Output:
%
% dat   Struct, contains all the parameters and the scans from the .ccl
%       file.
%

if nargin < 2
    mon0 = 1000;
end

fid = fopen(fName);

l1 = fgetl(fid);

if ~strcmp(l1,'CCL')
    error('import_ccl:WrongFile','Wrong file format!')
end

% read parameters
param = struct('name',{},'label',{},'value',{});

while ~strcmp(l1,'#data')
    l1 = fgetl(fid);
    % get the values
    v1 = strtrim(strsplit(l1,'='));
    if numel(v1) > 1
        param(end+1).name = v1{1}; %#ok<AGROW>
        
        if strcmp(v1{1},'date')
            v2 = datestr(v1{2});
        else
            v2 = sscanf(v1{2},'%f')';
        end
        if isempty(v2)
            param(end).value  = v1{2};
        else
            param(end).value  = v2;
        end
        param(end).label  = '';
    end
end

refIdx = 1;

scan = struct('x',{},'y',{},'e',{},'hkl',{},'T',{},'mon',{});
% read reflections
while ~feof(fid)
    l1  = fgetl(fid);
    p1  = sscanf(l1,'%f');
    hkl = p1(2:4)';
    xC  = p1(6);
    l2  = fgetl(fid);
    p2  = strsplit(strtrim(l2));
    if refIdx == 1
        param(end+1).name = 'xLabel'; %#ok<AGROW>
        param(end).value  = p2{8};
        param(end).label  = '';
    end
    dx  = sscanf(p2{9},'%f');
    nP  = sscanf(p2{1},'%d');
    mon = sscanf(p2{3},'%d');
    T   = sscanf(p2{4},'%f');
    CNTS = sscanf(fgetl(fid),'%d');
    nLine = ceil(nP/numel(CNTS));
    for ii = 1:(nLine-1)
        CNTS = [CNTS;sscanf(fgetl(fid),'%d')]; %#ok<AGROW>
    end
    
    scan(refIdx).x = (((-(nP-1)/2):((nP-1)/2))*dx + xC)';
    % arbitrary scaling
    scan(refIdx).y   = CNTS*mon0/mon;
    scan(refIdx).e   = sqrt(CNTS)*mon0/mon;
    scan(refIdx).hkl = hkl;
    scan(refIdx).T   = T;
    scan(refIdx).mon = mon;
    refIdx = refIdx + 1;
    
end

dat.scan  = scan;
dat.param = param;
fclose(fid);

end