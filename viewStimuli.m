fname = 'SupplememtaryTable2.csv';
opts = detectImportOptions(fname);
%opts = setvartype(opts,'Number','uint8');

T = readtable(fname, opts);
T.Number = cellfun(@(x) str2num(x), T.Number, 'UniformOutput', false);
%%
% loop over 3 datasets (datasets 3 and 4 use the same stimuli)
for ds = 1:3
    load(sprintf('stimuli-dataset%02d', ds), 'stimuli');
    rows = find(contains(T.Dataset, sprintf('DS%d',ds)));
    n = length(rows);
    numstim = cellfun(@length, T.Number(rows));
    c = max(numstim);
    
    figure(ds); clf; t=tiledlayout(n, c); t.TileSpacing =  'none';
    for r = 1:n
        thisrow = rows(r);
        for col = 1:c
            nexttile;
            if col <= numstim(r)
                imshow(0.5+squeeze(stimuli(:,:,1, T.Number{thisrow}(col))));
            else
                axis off;
            end
        end
    end
end