function plot1(D,varargin)
% plot 1D map of binned data

dat = D.raw.sig.val;
dat(isnan(dat)) = 0;

X = D.raw.ax(1).val;

plot(X,dat,varargin{:});
xlabel(D.raw.ax(1).label)
ylabel(D.raw.sig.label)

end