function [xx,yy,zz,ee] = surf_D20(dat,varStr)

if nargin < 2
    varStr = 'Tsample (k)';
end

lIdx = strcmp({dat{1}.par(:).name},varStr);

nDat = numel(dat);
T    = zeros(1,nDat);

for ii = 1:nDat
    T(ii) = dat{ii}.par(lIdx).value;
end

[xx,yy] = ndgrid(dat{1}.ax.value,T);
zz = xx;
if nargout > 3
    ee = zz;
end

for ii = 1:nDat
    zz(:,ii) = dat{ii}.sig.value./dat{ii}.mon.value;
    if nargout > 3
        ee(:,ii) = dat{ii}.err.value./dat{ii}.mon.value;
    end
end

p1 = surf(xx,yy,zz);
set(p1,'edgealpha',0)
view(2)
colormap(jet)
axis tight
xlabel('Scattering angle (deg)')
ylabel(varStr)
set(gca,'fontsize',12)
box on
end