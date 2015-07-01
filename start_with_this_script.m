%% save nxspe file

fDir  = '~/Desktop/YBCF_data_80meV/';
fName = 'YBCO_*.nxspe';

h5fName = 'YBCF_1.hdf';
nBin    = [20 20 20];
fList   = dir([fDir fName]);
fIdx    = 1:numel(fList);
cFact   = 0.1; % chunk size in unit of the pixel number
try
    delete([fDir h5fName]);
end

t1= clock;
save_dat(fDir,fList(fIdx),h5fName,nBin,cFact);
t2 = clock;
etime(t2,t1)
% 6.5 min for full dataset
% 15.9 min for Horace

%% bin nxspe file

fDir    = '~/Desktop/YBCF_data_80meV/';
h5fName = 'YBCF_1.hdf';

binQx = linspace(-3,3,101);
binQy = [-3 3];
binQz = linspace(-3,3,101);
binE  = [20 25];

profile on
t1 = clock;
D = load_dat(fDir,h5fName,binQx,binQy,binQz,binE);
profile off
squeeze(D)
t2 = clock;
etime(t2,t1)
plot(D)
colormap(jet)
caxis([0 800])
% typical cut 26s
% Horace 16s
