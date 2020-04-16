cd('/Users/jonathanwinawer/matlab/toolboxes/StdVisualModel/Data/Stimuli/');
for ii = 1:4
    
    load(sprintf('stimuli-dataset%02d_orig.mat', ii));
    n = size(stimuli,1);
    if ii == 2, stimuli = permute(stimuli, [2 1 3 4]); end
        
    switch ii
        case {1, 2}, idx = 10;
        case {3, 4}, idx = 12;
    end
    
%     figure(ii)
%     imshow(stimuli(:,:,1,idx));
    
    F = abs(fft(stimuli(:,n/2, 1, idx)));
    subplot(2,2,ii)
    plot(0:n-1, F);title(n);
    xlim([30 70])
end

%%
cd('/Users/jonathanwinawer/matlab/toolboxes/StdVisualModel/Data/Stimuli/');
for ii = 1:4
    
    load(sprintf('stimuli-dataset%02d_orig.mat', ii), 'stimuli');
    
    stimuli = double(stimuli)./255 - .5;
    
    if ii == 2, n = 150*1.5; else, n = 150; end
    
    stimuli = imresize(stimuli, [n n], 'bilinear');
        
    save(sprintf('stimuli-dataset%02d.mat', ii), 'stimuli');
    
end