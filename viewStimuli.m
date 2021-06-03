function [] = viewStimuli( data_set, pattern, variation)
    %{
        View stimuli indexed by dataset pattern, variation

        1. Input data set, pattern and variation to view the stimuli
        and the corresponding wave amplitude. 
        e.g. viewStimuli( 1, 'CURVES', 'density')
            Note data set should be a int, 
                 pattern should be a uppercase string,
                 vairation should be a lowercase string.
        
        2. If only data set is input: it displays all stimuli families 
        in the selected data set. 
        e.g. viewStimuli(1)
        
        3. If nothing is passed through the function: it displays all stimuli
        and all dataset
        e.g. viewStimuli()
    %}

    % load the table 
    fname = 'tables/SupplememtaryTable2.csv';
    opts = detectImportOptions(fname);
    %opts = setvartype(opts,'Number','uint8');
    imcontrast = @(x) round(1000*(max(x(:))-min(x(:))))/10;
    T = readtable(fname, opts);
    T.Number = cellfun(@(x) str2num(x), T.Number, 'UniformOutput', false);

    % select the rows, 
    if (nargin<1)
        select_datasets = 1:3;
    else
        select_datasets = data_set;
    end

    % loop over 3 datasets (datasets 3 and 4 use the same stimuli)
    for ds = select_datasets
        load(sprintf('Data/Stimuli/stimuli-dataset%02d', ds), 'stimuli');
        rows = find(contains(T.Dataset, sprintf('DS%d',ds)));
        n = length(rows);
        numstim = cellfun(@length, T.Number(rows));
        %c = max(numstim);
        if (nargin<2)
            select_rows = 1:n; 
        else
            pat_rows = find(contains(T.Pattern(rows), pattern));
            var_rows = find(contains(T.Variation(rows), variation));
            select_rows = intersect( pat_rows, var_rows);
        end

        for r = select_rows
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
                sim_size = size( stimuli, 1);         
            end
            for col = 1:numstim(r)
                nexttile;            
                thisim = squeeze(stimuli(:,:,1,T.Number{thisrow}(col)));
                if ds == 2
                    plot(thisim( floor(sim_size/2),:)); ylim([-0.5 .5]);
                else
                    plot(thisim(:, floor(sim_size/2))); ylim([-0.5 .5]);
                end
                title(sprintf('%3.2f Contrast', imcontrast(thisim)));
            end
        end
    end