%% directories

par_file = '~/Desktop/YBCF_data_80meV/ARCS_2x1_grouping.par';
sqw_file = '~/Desktop/YBCF_data_80meV/ybcf_80meV.sqw';
tmpdir   = '~/Desktop/YBCF_data_80meV/horace_tmp/';
indir    = '~/Desktop/YBCF_data_80meV/';

%% crystal parameters

%direct geometry
emode  = 1;
alatt  = [3.875 3.875 7.679];
angdeg = [90,90,90];
% vector || incident beam
u      = [1 0 0];
% vector perpendicular to the incident beam,
% pointing towards the large angle detectors on Merlin in the horizontal plane
v      = [0 1 0];
%offset angles in case of crystal misorientation (see the Horace manual for details)
omega  = 0.0;
%dpsi   = 0.0;
%gl     = 0.0;
%gs     = 0.0;

% Corrected values
dpsi = -2.64;
gl   = -0.87;
gs   = -1.31;


%% Ei = 80 meV, normalized

fName  = dir([indir '*.nxspe']);
fName = {fName.name};

% convert data to sqw
nfiles = numel(fName);
psi      = zeros(nfiles,1);
efix     = zeros(nfiles,1);
spe_file = cell(nfiles,1);

for idx = 1:nfiles
    spe_file{idx} = [indir fName{idx}];
    efix(idx)     = h5read(spe_file{idx},'/data/NXSPE_info/fixed_energy');
    %psi(idx)      = h5read(spe_file{idx},'/data/NXSPE_info/psi');
    
    [~,tName] = fileparts(fName{idx});
    temp      = sscanf(strrep(strrep(tName(13:end),'p','.'),'_',' '),'%f %f %f');
    T(idx)     = temp(2);
    psi(idx)   = temp(3);

    
end
fprintf('Number of files ready to convert: %d.\n',nfiles);

t1 = clock;
gen_sqw(spe_file,par_file,sqw_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
t2 = clock;
etime(t2,t1)

%% bin

proj.uoffset = [0 0 0];
proj.type    = 'ppr';
% (H,K,0) scattering plane
proj.u = [1 0 0];
proj.v = [0 1 0];

% symmetrize all data
Q1 = [-2 0.04 2];
Q2 = [-2 0.04 2];
Q3 = [-6 6];
E0 = [20 25];

t1 = clock;
dat1s = cut_sqw(sqw_file,proj,Q1,Q2,Q3,E0);
t2 = clock;
etime(t2,t1)
% 16s s
