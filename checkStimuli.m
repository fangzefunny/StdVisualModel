pix2deg = 12.5 / 150;

% check densities
figure(1)

t=tiledlayout(3,5);
load stimuli-dataset01.mat;figure(1)
for ii=1:5
    nexttile
    imshow(stimuli(:,:,1,ii)+0.5); axis on
end

load stimuli-dataset02.mat;
for ii=1:5
    nexttile
    imshow(stimuli(1:150,1:150,1,ii)+0.5); axis on
end
load stimuli-dataset03.mat;

idx = [39 30 38 37 36];
%idx = 22:2:30;
for ii=1:5
    thisim = idx(ii);
    nexttile
    imshow(stimuli(1:150,1:150,1,thisim)+0.5); axis on
end

t.TileSpacing = 'compact';



%% Note that SOC paper had one extra curves/density image that we did not use:
load ~/Downloads/socmodel/stimuli.mat;
figure(9), clf; t=tiledlayout(1,5);
idx = [ 184 29+56 183 182 181];
for ii = idx
    nexttile();
    imshow(.5+images{ii}(:,:,1));
    
end

%% check densities
figure(2)

load stimuli-dataset01.mat;
for ii=1:5
    subplot(3,5,ii);
    plot(stimuli(80,:,1,ii)+0.5); 
    axis([0 150 .2 .8])
end

load stimuli-dataset02.mat;
for ii=1:5
    subplot(3,5,ii+5);
    plot(stimuli(80,1:150,1,ii)+0.5); 
    axis([0 150 .2 .8])
end

load stimuli-dataset03.mat;
for ii=1:4
    subplot(3,5,ii+10);
    plot(stimuli(80,1:150,1,(5-ii)+35)+0.5); 
    axis([0 150 .2 .8])
end


%% check densities
load stimuli-dataset01.mat;
figure(3); clf

[fsx, fsy] = meshgrid((-75:74)/12.5);  
fs = sqrt(fsx.^2+fsy.^2);

th = linspace(0, 2*pi, 100);
r  = ones(size(th));


for ii=1:5
    A = abs(fft2(stimuli(:,:,:,ii)));
    A = mean(A,3);
    subplot(3,5,ii);
    imagesc(fsx(:), fsy(:), (fftshift(A)));
    axis square;
    hold on,
    polar(th, r*1.4, 'k--');
    polar(th, r*3, 'k-');
    polar(th, r*4.7, 'k--');
end

load stimuli-dataset02.mat;
for ii=1:5    
    A = abs(fft2(stimuli(1:150,1:150,:,ii)));
    A = mean(A,3);
    subplot(3,5,ii+5);
    imagesc(fsx(:), fsy(:), (fftshift(A)));
    axis square;      
    hold on,
    polar(th, r*1.4, 'k--');
    polar(th, r*3, 'k-');
    polar(th, r*4.7, 'k--');
end


load stimuli-dataset03.mat;
for ii=1:4    
    A = abs(fft2(stimuli(1:150,1:150,:,(5-ii)+35)));
    A = mean(A,3);
    subplot(3,5,ii+10);
    imagesc(fsx(:), fsy(:), (fftshift(A)));
    axis square;      
       
    hold on,
    polar(th, r*1.4, 'k--');
    polar(th, r*3, 'k-');
    polar(th, r*4.7, 'k--');
end

%%
figure(5), clf

[fsx, fsy] = meshgrid((-75:74)/12.5);  
fs = sqrt(fsx.^2+fsy.^2);
th = linspace(0, 2*pi, 100);
r  = ones(size(th));

for ii = 1:3
    load(sprintf('stimuli-dataset0%d.mat',ii));
    A = abs(fft2(stimuli(1:150,1:150,:,:)));
    A = mean(A,4);
    A = mean(A,3);
    subplot(3,2,2*ii-1);
    imagesc(fsx(:), fsy(:), (fftshift(A)));
    axis square;
    
    hold on,
    polar(th, r*1.4, 'k--');
    polar(th, r*3, 'k-');
    polar(th, r*4.7, 'k--');
    
    subplot(3,2,2*ii);
    B = fftshift(A);
    scatter(fs(:), B(:), '.'); axis([0 8 0 12]); grid on; hold on;
%     [x, idx] = sort(fs(:));
%     y = B(idx);
%     y = smooth(x,y, 500, 'lowess');
%     plot(x, y, '-')
%     axis([0 8 0 12]);
end