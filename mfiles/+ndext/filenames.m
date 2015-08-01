function [fName,fDir, brSel, sySel] = filenames(filedesc)
% extracts list of filenames from strings using Matlab like syntax
%
% [fNames,fDir, {bracket}, {symbol}] = filenames(filedesc)
%
% The filedesc contains a string with integer numbers enclosed by on of the
% following brackets: [],{},(). Within the bracket there can be up to 3
% integer numbers that will generate a vector similarly to the standard
% Matlab notation:
%
% [N1]                      --> v = N1
% [N1 symbol N2]            --> v = N1:1:N3
% [N1 symbol N2 symbol N3]  --> v = N1:N2:N3
%
% The symbol can be one of the following characters:
% !,",#,$,%,&,',*,+,:,;,<,>,?,^,` and whitespace.
%
% In the file name description only a single type of bracket and one type
% symbol is allowed at once. For example a valid file name description:
%
% folder/myfiles001[23*2*28]
%
% This string will generate the following filenames:
% fNames = {'myfiles00123' 'myfiled00125' 'myfiles00127'}
% fDir   = 'folder'
% bracket = '[]';
% symbol  = '*';
%

bracket = '[]{}()';
symbol  = '!"#$%&*+:;<>?^`'' ';

% check for a common error: wrong file separator
if filesep == '/' && any(filedesc=='\')
    error('ndext:filenames:WrongInput','Wrong file name separator is used, use ''/'' instead!')
elseif filesep == '\' && any(filedesc=='\')
    error('ndext:filenames:WrongInput','Wrong file name separator is used, use ''/'' instead!')
end

% separate the folder name from the file
dirIdx = find(filedesc==filesep,1,'last');

if isempty(dirIdx) || dirIdx == 1
    fDir = '';
else
    fDir = filedesc(1:(dirIdx-1));
    filedesc = filedesc((dirIdx+1):end);
end

% check the brackets and symbols
[isbracket,brIdx] = ismember(filedesc,bracket);
[~,syIdx] = ismember(filedesc,symbol);

% bracket location
brLoc = find(brIdx);
brIdx = brIdx(brIdx>0);
% symbol location
syLoc = find(syIdx);
syIdx = syIdx(syIdx>0);


if numel(brIdx) == 0
    if numel(syIdx) == 0
        % single file name
        fName = filedesc;
        if nargout >2
            brSel = '';
            sySel = '';
        end
        
        return
    else
        error('ndext:filenames:WrongInput','Missing brakets in file name!')
    end
end

if numel(brIdx)==1 || numel(brIdx)>2 || diff(brIdx)~=1 || mod(brIdx(1),2)==0
    error('ndext:filenames:WrongInput','The file name has to contain a single pair of bracket!')
end

if numel(syIdx)==0
    fName = filedesc(~isbracket);
    if nargout >2
        brSel = bracket(brIdx);
        sySel = '';
    end
    
    return
end

if numel(syIdx)>2 || syLoc(1)<brLoc(1) || syLoc(end)>brLoc(2)
    error('ndext:filenames:WrongInput','In the file name the symbols should be inside the brackets')
end

% keep the filename outside of the brackets
lFile = filedesc(1:(brLoc(1)-1));
rFile = filedesc((brLoc(2)+1):end);
cFile = filedesc((brLoc(1)+1):(brLoc(2)-1));

% relative location of symbols
%syLoc = syLoc - brLoc(1);

% extracts numbers
nums = str2double(strsplit(cFile,symbol(syIdx(1))));

if any(isnan(nums))
    error('ndext:filenames:WrongInput','In the file name string inside the brackets only integer are allowed!')
end

% create numors
if numel(nums)==2
    nums = nums(1):nums(2);
else
    nums = nums(1):nums(2):nums(3);
end

fName = num2str(nums',[lFile '%d' rFile]);
% conver the string into a cell of filenames
fName = strtrim(mat2cell(fName,ones(1,numel(nums)),size(fName,2)));

if nargout >2
    brSel = bracket(brIdx);
    sySel = symbol(syIdx(1));
end

end