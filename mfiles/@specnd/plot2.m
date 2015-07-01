function plot2(D,varargin)
% plot 2D map of binned data

cBin = D.raw.axis.value(1:2);
% calculate bin edges
% bins with single element gets a +/- 0.5 width
for ii = 1:2
    if numel(cBin{ii}) == 1
        eBin{ii} = cBin{ii}+[-0.5 0.5]';
    else
        cc = cBin{ii};
        eBin{ii} = [(3*cc(1)-cc(2))/2; (cc(1:end-1)+cc(2:end))/2; (3*cc(end)-cc(end-1))/2];
    end
end

[xx,yy] = ndgrid(eBin{:});

dat = D.raw.datcnt.value;
dat(isnan(dat)) = 0;

% add extra pad for surf plot
dat(end+1,:)=0;
dat(:,end+1) = 0;

sHandle = surf(xx,yy,dat);
set(sHandle,'edgealpha',0)
axis([eBin{1}([1 end])' eBin{2}([1 end])']);
view(2)
xlabel(D.raw.axis.label{1})
ylabel(D.raw.axis.label{2})
zlabel(D.raw.datcnt.label)

end