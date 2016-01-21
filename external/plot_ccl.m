function plot_ccl(ccl,hkl, subw, permIt)
% plot selected reflections from imported ccl data
%
% PLOT_CCL(cclDat,hklList,{subFigSize},{permIt})
%
% If a reflection cannot be found in cclDat, no error will be returned,
% just it will be skipped.
%
% Input:
%
% cclDat        Data imported using the import_ccl() function.
% hklList       Matrix with dimensions [nHkl 3], the list of reflections to
%               plot.
% subFigSize    Number of subplots per figure.
%

sIdx = [];
hklP = zeros(0,3);
hkl0 = reshape([ccl.scan(:).hkl]',3,[])';

if nargin==4 && permIt && size(hkl,1)==1
    % add all sign permutations of Q
    pp = [1 1 1; -1 1 1;1 -1 1;1 1 -1;-1 -1 1;-1 1 -1;1 -1 -1;-1 -1 -1];
    hkl = bsxfun(@times,hkl,pp);
end

for ii = 1:size(hkl,1)
    sIdx0 = find(sum(abs(bsxfun(@minus,hkl0,hkl(ii,:))),2)==0);
    sIdx = [sIdx sIdx0]; %#ok<AGROW>
    hklP = [hklP; repmat(hkl(ii,:),numel(sIdx0),1)]; %#ok<AGROW>
end

nIdx = numel(sIdx);

if nargin<2
    subw = ceil(sqrt(nIdx));
end
if numel(subw) == 1
    subw = [subw subw];
end

scan = ccl.scan(sIdx);

for ii = 1:numel(sIdx)
    subplot(subw(1),subw(2),ii);
    
    errorbar(scan(ii).x,scan(ii).y,scan(ii).e,'o-')
    xlabel(ccl.param(end).value)
    set(gca,'fontsize',16)
    title(num2str([hklP(ii,:) scan(ii).T scan(ii).mon],'Q = [%g,%g,%g], T = %6.2f K, MON = %g'))
    grid on
end

end

