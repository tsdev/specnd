function plot1(D,varargin)
% plot 1D map of binned data

dat = D.raw.datcnt.value;
dat(isnan(dat)) = 0;

X = D.raw.axis.value{1};

plot(X,dat,varargin{:});
xlabel(D.raw.axis.label)
ylabel(D.raw.datcnt.label)

end