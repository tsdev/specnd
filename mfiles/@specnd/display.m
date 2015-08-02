function display(D) %#ok<DISPLAY>
% displays the content of a specnd object

% set the output file identifier
fid = getparam(D,'fid');

modes = {'event mode' 'histogram mode'};

fprintf0(fid,'specnd object\n');
fprintf0(fid,'Data is in %s.\n',modes{ishistmode(D)+1});
fprintf0(fid,'Data dimensions (nDim):   %3d\n',ndim(D));
fprintf0(fid,'Number of channels (nCh): %3d\n',nch(D));
fprintf0(fid,['Axis length (nAxis):     [' num2str(naxis(D)) ']\n']);

% show all subfield of .raw
fprintf0(fid,'\nsubfields of raw:\n...\n');

end