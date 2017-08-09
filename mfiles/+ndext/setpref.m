function setpref(prefName, value)
% sets specnd global preferences
%
% ndext.setpref(prefName, value)
%
% Sets the value of the prefName specnd global preferences.
%
% ndext.setpref('default')
%
% Resets all preferences values to the default one.
%
% See also ndext.getpref.
%

% the storage name within built-in getpref/setpref
store = 'specnd_global';

pidNow = feature('getpid');

if ispref(store) && getpref(store,'pid')~=pidNow
    rmpref(store);
end

setpref(store,'pid',pidNow);

if strcmp(prefName,'default')
    if ispref(store)
        rmpref(store);
    end
    setpref(store,'pid',pidNow);
    return
end

if strcmp(prefName,'pid')
    warning('ndext:getpref:Locked','pid value can not be changed!')
    return
end

% check if the preference name exists
dPref = ndext.getpref('default');

iPref = find(strcmp(prefName,{dPref(:).name}),1,'first');
if ~isempty(iPref)
    % check if the preferences label contains a choice string
    str0 = strsplit(dPref(iPref).label,' ');
    opt0 = strsplit(str0{end},'/');
    
    if numel(opt0) > 1
        % there is a choice of different string options
        if ~ischar(value) || ~any(strcmp(value,opt0))
            error('ndext:setpref:WrongInput',['The selected preference has a restricted choice: ' str0{end} '!'])
        end
        setpref(store,prefName,value);
    else
        % the value has to be a scalar
        % TODO check for other type of values
        setpref(store,prefName,value);
    end
    
else
    error('ndext:setpref:WrongName','The given name is not a valid specnd global preferences!');
end

end