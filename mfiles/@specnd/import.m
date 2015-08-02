function import(D,filedesc,fun,axisdesc, varargin)
% imports data into a specnd object.
%
% import(D,filedesc,@importfun,axisdesc, 'option1', value1 ...)
%

% extract filenames from filedesc
[fName,fDir, brSel, sySel] = ndext.filenames(filedesc);

if ischar(fun)
    if strcmpp(fun,'auto')
        param.auto = true;
    else
        try
            fun = str2fun(fun);
        catch
            error('specnd:import:WrongInput',['The import function has '...
                'to be either the name of the function, function handle '...
                'or the string ''auto''!']);
        end
    end
end
% extract axis assignments from the axisdesc string


















end