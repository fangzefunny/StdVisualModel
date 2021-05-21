pix2deg = 12.5 / 150;

% check densities
figure(1)

t=tiledlayout(3,5);
load stimuli-dataset01.mat;figure(1)
for ii=1:5
    nexttile
    imshow(stimuli(:,:,1,ii)+0.5); 
end

load stimuli-dataset02.mat;
for ii=1:5
    nexttile
    imshow(stimuli(1:150,1:150,1,ii)+0.5); 
end
load stimuli-dataset03.mat;

idx = 36:39; % 30
for ii=idx
    thisim = ii;
    nexttile
    imshow(stimuli(1:150,1:150,1,thisim)+0.5); 
end

t.TileSpacing = 'none';

%% check densities
load stimuli-dataset01.mat;
figure(2); clf

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
figure(3), clf

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

end



%% Note that SOC paper had one extra curves/density image that we did not use:
load stimuli_kay.mat;
figure(9), clf; t=tiledlayout(1,5);
idx = [ 184 29+56 183 182 181];
for ii = idx
    nexttile();
    imshow(.5+images{ii}(:,:,1));
    
end


%% Compare STRIPES (density) to STRIPES (contrast)
load stimuli_kay.mat;

load stimuli-dataset03.mat;
figure(1), 

% grating density (150 x 150 images)

subplot(2,6,1);
imagesc(squeeze(stimuli(:,:,1,1))+0.5, [0 1]); axis image; colormap gray;
subplot(2,6,7);
plot(stimuli(:,75,1,1)); ylim([-.4 .3])

for ii = 1:5
    subplot(2,6,1+ii);
    imagesc(squeeze(stimuli(:,:,1,30+ii))+0.5, [0 1]); axis image; colormap gray;
    
    subplot(2,6,7+ii);
    plot(stimuli(:,75,1,30+ii)); ylim([-.4 .3])
end



figure(2)

% density for full resolution images
subplot(2,6,1);
imagesc(images{139}(:,:,1), [0 255]); axis image; colormap gray;
subplot(2,6,7);
plot(images{139}(:,300,1));ylim([0 255])

for ii = 1:5
    subplot(2,6,1+ii);
    imagesc(images{175+ii}(:,:,1), [0 255]); axis image; colormap gray;
    
    subplot(2,6,7+ii);
    plot(images{175+ii}(:,300,1));ylim([0 255])
end


figure(4)
scatter(images{139}(:,300,1), images{176}(:,300,1))


% contrast for dataset 1
figure(5) ; clf
load stimuli-dataset01.mat;
stims = [35 36 8 37 38];
for ii = 1:length(stims)
    idx = stims(ii);
    subplot(2,length(stims)+1,ii+1);
    imagesc(squeeze(stimuli(:,:,1,idx))+0.5, [0 1]); axis image; colormap gray;
    
    subplot(2,6,length(stims)+2+ii);
    plot(stimuli(:,75,1,idx)); ylim([-.4 .3])
end