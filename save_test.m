%%

A = rand(20,1000,1200,40,'int32');  % 48M int32s => 184 MB
B = randn(500,1000,20);              % 80M doubles => 78 MB
ops.algo = 'test';                   % non-numeric

tic, save('test1.mat','-v7','ops','A','B'); toc
% => Elapsed time is 11.940455 seconds.   % file size: 114 MB

tic, save('test2.mat','-v7.3','ops','A','B'); toc
% => Elapsed time is 6.963135 seconds.    % file size: 116 MB

tic, savefast('test3.mat','ops','A','B'); toc
% => Elapsed time is 3.164903 seconds.   % file size: 259 MB

%%

A = rand(5000);

tic, save('test1.mat','-v7','A'); toc
% => Elapsed time is 11.940455 seconds.   % file size: 114 MB

tic, save('test2.mat','-v7.3','A'); toc
% => Elapsed time is 6.963135 seconds.    % file size: 116 MB

tic, savefast('test3.mat','A'); toc
% => Elapsed time is 3.164903 seconds.   % file size: 259 MB

%%

A = rand(1e4);
tic
h5create('test4.h5','/DS1',[1e4 1e4]);
toc
tic
h5write('test4.h5', '/DS1',A);
toc


%% typical TOF dataset


npix = 1e5;
nang = 180;
ne = 400;

Npoint = npix*nang*ne;

% to store: (h,k,l,I,E)
%%

%A = randi(2^16,1,5e9,'int16');
A = rand(1e9,1,'single');

tic
h5create('test4.h5','/DS1',[1e9 Inf],'Datatype','single','ChunkSize',[1e7 1]);
toc
tic
for ii = 1:5
    h5write('test4.h5', '/DS1',A,[1 ii],[1e9 1]);
end
toc
% Elapsed time is 54.851386 seconds.
h5disp('test4.h5');

%%

h5create('myfile.h5','/DS3',[20 Inf],'ChunkSize',[5 5]);
for j = 1:10
    data = j*ones(20,1);
    start = [1 j];
    count = [20 1];
    h5write('myfile.h5','/DS3',data,start,count);
end
h5disp('myfile.h5');



%% simulate data

h5create('test1.sqw','/DS1',[1e7 Inf],'Datatype','single','ChunkSize',[1e6 1]);

nPhi = 10;
phi = linspace(10,20,nPhi);

profile on
%sw_status(0,1)

for ii = 1:nPhi
    
    Ei      = 20; % meV
    ki      = sw_converter(Ei,'meV','A-1');
    A1tomeV = sw_converter(1,'A-1','meV');
    EN      = linspace(-Ei,Ei,200);
    kf      = sqrt(ki^2-EN/A1tomeV);
    
    theta1  = 180*(rand(1,5e4)-0.5);
    theta2  =  20*(rand(1,5e4)-0.5);
    
    [theta11,~] = ndgrid(theta1,kf);
    [theta22,kff] = ndgrid(theta2,kf);
    
    theta11 = theta11(:);
    theta22 = theta22(:);
    kff = kff(:);
    
    Q = zeros(3,numel(kff),'single');
    
    Q(1,:) = kff.*cosd(theta22).*sind(theta11);
    Q(2,:) = ki - kff.*cosd(theta22).*cosd(theta11);
    Q(3,:) = kff.*sind(theta22);
    
    % rotation
    [~,R] = sw_rot([0 0 1],phi(ii)*pi/180);
    
    Q = R*Q;
    
    CNTS = round(rand(1,numel(kff),'single')*1e5);
    ERR  = sqrt(CNTS);
    
    
    h5write('test1.sqw', '/DS1',[Q; CNTS; ERR]',[1 5*ii-4],[1e7 5]);
    %sw_status(ii/nPhi*100)
end
%sw_status(100,2)
profile off

% calculate+write 2s per phi angle, 1.86GB per phi angle
% full dataset 3 min

h5disp('test1.sqw');

%% load data and make a cut


% constant energy cut
E = 0;
nE = numel(EN);

idxE = find(abs(EN-E)==min(abs(EN-E)),1,'first');

nBin = 100;

QHbin = linspace(-5,5,nBin);
QKbin = linspace(-5,5,nBin);

M = zeros(nBin);
tic
for ii = 1:10
    Dat1 = h5read('test1.sqw','/DS1',[1 5*ii-4],[1e7 5]);
    step = size(Dat1,1)/nE;
    % select E values
    Dat1 = Dat1(((idxE-1)*step+1):((idxE)*step),:);
    
    idx1 = round(interp1(QHbin,1:nBin,Dat1(:,1),'linear'));
    idx2 = round(interp1(QKbin,1:nBin,Dat1(:,2),'linear'));
    
    M = M + accumarray([idx1 idx2],Dat1(:,4),[nBin nBin]);
    
end
toc
figure;
imagesc(M)











