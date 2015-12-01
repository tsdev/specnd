function log_D20(fName)

xml1 = fileread(fName);
xml1 = strsplit(xml1,char([10 9]));

entry = struct;

for ii = 2:numel(xml1)
    line = strtrim(xml1{ii});
    line = strsplit(line(8:(end-3)),'" ');
    for jj = 1:(numel(line))
        piece = strsplit(line{jj},'="');
        piece{1}(piece{1}==' ') = '_';
        entry(ii-1).(piece{1}) = piece{2};

    end
end

log = struct;

% find new numors entries
sIdx = find(cellfun(@(C)~isempty(C),{entry(:).start_time}));
eIdx = find(cellfun(@(C)~isempty(C),{entry(:).end_time}));

% split up according to numor
%log(1).numor = [];
%log(1).entry = entry(1:(sIdx(1)-1));

for ii = 1:(numel(sIdx)-1)
    log(ii+1).numor = entry(nIdx(ii)).numor;
    log(ii+1).entry = entry((nIdx(ii)+1):(nIdx(ii+1)-1));
end
log(nIdx+1).numor = entry(nIdx(end)).numor;
log(nIdx+1).entry = entry((nIdx(end)+1):end);

end








