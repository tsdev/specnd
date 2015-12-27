function plot_D20(dat,varargin)

if ~iscell(dat)
    dat = {dat};
end

lIdx = strcmp({dat{1}.par(:).name},'Tsample (k)');

for ii = 1:numel(dat)
    
    if ii > 1
        hold on
    end
    
    Ts = dat{ii}.par(lIdx).value;
    plot(dat{ii}.ax.value,dat{ii}.sig.value./dat{ii}.mon.value);
    
    lStr = getappdata(gcf,'legend');
    
    if isempty(lStr)
        lStr = {};
    end
    
    lStr{end+1} = num2str(Ts,'T_s = %6.2f K'); %#ok<AGROW>
    legend(lStr);
    setappdata(gcf,'legend',lStr);
    
end

axis tight
box on
xlabel('Scattering angle (deg)')
ylabel('Intensity (arb. units)')
set(gca,'fontsize',12)

end