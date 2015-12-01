function datC = combine_D20(dat)

datC = dat{1};

sig = dat{1}.sig.value;
er2 = dat{1}.err.value.^2;
mon = dat{1}.mon.value;

for ii = 2:numel(dat)
    sig = sig + dat{ii}.sig.value;
    er2 = er2 + dat{ii}.err.value.^2;
    mon = mon + dat{ii}.mon.value;
end

datC.sig.value = sig;
datC.err.value = sqrt(er2);
datC.mon.value = mon;

end