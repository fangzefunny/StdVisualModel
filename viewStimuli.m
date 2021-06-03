fname = 'SupplememtaryTable2.csv';
opts = detectImportOptions(fname);
%opts = setvartype(opts,'Number','uint8');
imcontrast = @(x) round(1000*(max(x(:))-min(x(:))))/10;
T = readtable(fname, opts);
T.Number = cellfun(@(x) str2num(x), T.Number, 'UniformOutput', false);
%%
% loop over 3 datasets (datasets 3 and 4 use the same stimuli)
for ds = 3
    load(sprintf('stimuli-dataset%02d', ds), 'stimuli');
    rows = find(contains(T.Dataset, sprintf('DS%d',ds)));
    n = length(rows);
    numstim = cellfun(@length, T.Number(rows));
    %c = max(numstim);
    
    for r = 1:n
        thisrow = rows(r);
        figure(ds*100+r); clf; 
        t=tiledlayout(2, numstim(r)); 
        t.TileSpacing =  'none';
        set(gcf, 'NumberTitle', 'off', ...
            'Name', sprintf('Dataset %d, %s (%s)', ds, upper(T.Pattern{thisrow}), ...
            T.Variation{thisrow}));
        for col = 1:numstim(r)
            nexttile;            
            imshow(0.5+squeeze(stimuli(:,:,1, T.Number{thisrow}(col))));            
        end
        for col = 1:numstim(r)
            nexttile;            
            thisim = squeeze(stimuli(:,:,1,T.Number{thisrow}(col)));
            plot(thisim(:,75)); ylim([-0.5 .5]);
            title(sprintf('%3.2f Contrast', imcontrast(thisim)));
        end
    end
end