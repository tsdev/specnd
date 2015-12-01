function dat = bin_D20(dat,xbin)

if isempty(xbin)
    return;
end

dx = xbin(2)-xbin(1);

xbin2 = [xbin(:)-dx/2; xbin(end)+dx/2];

[dBin, nBin] = ndext.histn(dat.ax.value,dat.sig.value,xbin2,'emptyval',[0 1]);
dBin = dBin./nBin;
eBin = ndext.histn(dat.ax.value,dat.err.value.^2,xbin2,'emptyval',[0 1]);
eBin = eBin./nBin;

dat.ax.value  = xbin;
dat.sig.value = dBin;
dat.err.value = eBin;

end