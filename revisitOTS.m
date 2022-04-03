function revisitOTS(fig, ds, roi)
%{
    Function for the supplement document revisitOTS
    ds: dataset, default 1
    roi: region of interest, default 1, v1
    Inputs: fig, the corresponding figures for the document 
            S means section, H means the hypothesis put forward in the
            very section. 'S2H1' means section 2 hypothesis 1.
            - 'S2H1': compare the new and old fitlers
            - 'S2H2.1': compare the E with new and old filters
            - 'S2H2.2': compare the density effect of S with new and old filters varying w
            - 'S2H3': compare the contrast effect
            - 'S2H4.0': get the old contrast energy for all target parameters E.  
            - 'S2H4': compare the prediction of the old and new filters,
            make sure the 'H4.0' has been run at least once, before making
            this figure. 
            - 'S3H1':  check the std of the new filter
              
%}

% get default input
if (nargin < 3), roi = 1; end
if (nargin < 2), ds = 1; end

% get color
viz = ColorPalette(); 

switch fig
    
    % ------------------------ WHY OTS IS BETTER --------------------------%
    
    case 'S2H1'
        
        % get filter t
        [ Gabor_c, Gabor_s] = getFilters( 'new', ds) ;
        [ oGabor_c, oGabor_s] = getFilters( 'old', ds) ;
        
        % visualize the filters
        for i = 1:8
            subplot( 3, 8, i)
            x = oGabor_s{i};
            imshow(x, [ -.25, .25])
            title( sprintf('range:[%0.2f, %.2f]', [min(x(:)), max(x(:))]))
            subplot( 3, 8, 8+i)
            x = Gabor_s{i};
            imshow(x, [ -.25, .25])
            title( sprintf('range:[%0.2f, %.2f]', [min(x(:)), max(x(:))]))
            subplot( 3, 8, 16+i)
            x = Gabor_s{i}-oGabor_s{i};
            imshow(x, [-.25, .25])
            title(sprintf('range:[%0.2f, %.2f]', [min(x(:)), max(x(:))]))
        end
        
    case 'S2H2.1'
        
        % Get contrast energy
        [E_sna, oE_sna] = idx2CE( 3, ds, roi);
        [E_gra, oE_gra] = idx2CE( 8, ds, roi);
        
        % check the sum CE at different orientations
        Eori_gra = squeeze(mean(E_gra,[1,2,4]));
        Eori_sna = squeeze(mean(E_sna,[1,2,4]));
        oEori_gra = squeeze(mean(oE_gra,[1,2,4]));
        oEori_sna = squeeze(mean(oE_sna,[1,2,4]));
        
        % for orientation energy figure
        figure();
        Eori_g = horzcat( Eori_gra, oEori_gra);
        Eori_s = horzcat( Eori_sna, oEori_sna);
        subplot( 2, 2, 1)
        b1 = bar(Eori_g);
        Eori_g_rat = Eori_gra ./ oEori_gra;
        text(1:length(Eori_g_rat),oEori_gra, num2str(Eori_g_rat,'%.2f'),...
            'vert','bottom','horiz','center','FontSize', 8);
        b1(1).FaceColor = viz.Blue;
        b1(1).EdgeColor = viz.Blue;
        b1(2).FaceColor = viz.Blue .* .7;
        b1(2).EdgeColor = viz.Blue .* .7;
        xlabel( 'Orientation','FontSize', 12)
        ylabel( 'Averaged contrast energy','FontSize', 12)
        legend( 'New', 'Old')
        title( 'Gratings','FontSize', 12);
        ylim([0,.2])
        subplot( 2, 2, 2)
        b2 = bar(Eori_s);
        Eori_s_rat = Eori_sna ./ oEori_sna;
        text(1:length(Eori_s_rat),oEori_sna, num2str(Eori_s_rat,'%.2f'),...
            'vert','bottom','horiz','center','FontSize', 8);
        b2(1).FaceColor = viz.Red;
        b2(1).EdgeColor = viz.Red;
        b2(2).FaceColor = viz.Red .* .7;
        b2(2).EdgeColor = viz.Red .* .7;
        xlabel( 'Orientation','FontSize', 12)
        ylabel( 'Averaged contrast energy','FontSize', 12)
        legend( 'New', 'Old','FontSize', 12)
        title( 'Snakes');
        ylim([0,.2])
        subplot( 2, 2, 3)
        summary = [sum(Eori_gra), sum(oEori_gra); sum(Eori_sna), sum(oEori_sna)];
        b3 = bar(summary);
        Eori_rat = [ sum(Eori_gra), sum(Eori_sna)] ./ [ sum(oEori_gra), sum(oEori_sna)];
        text(1:length(Eori_rat),[ sum(oEori_gra), sum(oEori_sna)], num2str(Eori_rat','%.2f'),...
            'vert','bottom','horiz','center','FontSize', 8);
        b3(1).FaceColor = viz.Grey;
        b3(1).EdgeColor = viz.Grey;
        b3(2).FaceColor = viz.Grey.* .7;
        b3(2).EdgeColor = viz.Grey.* .7;
        ylabel( 'Averaged contrast energy','FontSize', 12)
        legend( 'New', 'Old','FontSize', 12)
        title( 'Sum over orientation');
        xticks([ 1, 2])
        xticklabels({'Gratings','Snakes'})
        
        
    case { 'S2H2.2', 'S2H3'}
        
        % check the density effect
        % dim1: old or new; 2
        % dim2: gratings or snakes; 2
        % dim3: contrast level; 5
        %cls = [ 35, 36, 8, 37, 38; 47, 48, 3, 49, 50];
         % visualize the filters
        colors = [  viz.Red; viz.Blue; viz.Red.*.7; viz.Blue.*.7];
        switch fig; case 'S2H2.2'; group='den'; case 'S2H3'; group='con'; end
        cls = getDataCls( ds, group) ;
        E_cls  = cell([2,size(cls)]);
        ep = 5;
        for i=1:size(cls,1)
            for j=1:size(cls,2)
                [E, oE] = idx2CE(cls(i,j), ds, roi, ep);
                E_cls{1,i,j} = E;
                E_cls{2,i,j} = oE;
            end
        end
        
        % Get OTS normalized energy
        % get filters
        F = getOTSFilters( E);
        sum_E  = nan([2,size(cls)]);
        sum_Z  = nan([2,size(cls)]);
        sum_D  = nan([2,size(cls)]);
        % get sum E, Z, D
        w = 50;
        for i=1:2
            for j=1:size(cls,1)
                for k=1:size(cls,2)
                    E = E_cls{i,j,k};
                    Z = calc_z( E, F);
                    sum_E(i,j,k) = mean(E(:));
                    sum_Z(i,j,k) = mean(Z(:));
                    D = E ./ ( 1 + w * Z);
                    sum_D(i,j,k) = mean(D(:));
                end
            end
        end
        % visualize the filters
        sum_vals = { sum_E, sum_Z, sum_D};
        titles = {'summed E', 'summed Z', 'S',...
            'scaled summed E', 'scaled summed Z', 'scaled S'};
        for k=1:length(sum_vals)
            x = sum_vals{k};
            subplot( 2, 3, k)
            for j=1:size(x,2)
                l = size(x,3);
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(1,j,:)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', colors(j,:), ...
                    'MarkerFaceColor', colors(j,:),...
                    'LineWidth', 3,...
                    'Color', colors(j,:))
                title( titles{k}, 'FontSize', 14)
                hold on
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(2,j,:)),...
                    '--','LineWidth', 2,...
                    'Color', colors(j+2,:))
                ylim([0, max(x(:))*1.2])
            end
            xticklabels('')
            subplot( 2, 3, k+3)
            for j=1:size(x,2)
                l = size(x,3);
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(1,j,:)./x(1,1,1)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', colors(j,:), ...
                    'MarkerFaceColor', colors(j,:),...
                    'LineWidth', 3,...
                    'Color', colors(j,:))
                title( titles{k+3}, 'FontSize', 14)
                hold on
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(2,j,:)./x(2,1,1)),...
                    '--','LineWidth', 2,...
                    'Color', colors(j+2,:))
            end
            xticklabels('')
            
        end
        sgtitle(sprintf('w=%d',w),'FontSize', 14', 'FontWeight', 'Bold')
        hold off
        
        ws = [ .1, 1, 10, 25, 50, 100, 500, 1000, 5000, 50000];
        g = [ 1, 1];
        n = [ 1, 1];
        sum_D  = nan([2,size(cls),length(ws)]); % oldNew x g-s x lvl x ws
        % get sum E, Z, D
        for wi = 1:length(ws)
            w = ws(wi);
            for i=1:2
                for j=1:size(cls,1)
                    for k=1:size(cls,2)
                        E = E_cls{i,j,k};
                        Z = calc_z( E, F);
                        D = E ./ ( 1 + w * Z);
                        x = g(i) .* mean(D, [1,2]).^n(i);
                        sum_D(i,j,k,wi) = mean(x(:));
                    end
                end
            end
        end
        % visualize the filters
        x  = sum_D;
        for k=1:length(ws)
            w = ws(k);
            subplot( 2, 5, k)
            for j=1:size(x,2)
                l = size(x,3);
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(sum_D(1,j,:,k)./sum_D(1,1,1,k)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', colors(j,:), ...
                    'MarkerFaceColor', colors(j,:),...
                    'LineWidth', 3,...
                    'Color', colors(j,:))
                title( sprintf('w=%.1f', w), 'FontSize', 14)
                hold on
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(sum_D(2,j,:,k)./sum_D(2,1,1,k)),...
                    '--','LineWidth', 2,...
                    'Color', colors(j+2,:))
            end
            xticklabels('')
            
        end
        titleStr = sprintf('Scaled s with varied w, DS=%d,V=%d, %s effect', [ds, roi, group]);
        sgtitle( titleStr,'FontSize', 14', 'FontWeight', 'Bold')
        hold off
        
        
    case 'S2H4.0'
        
        % get target data
        datasets  = [1, 4];
        
        % save address
        save_address = fullfile(stdnormRootPath, 'Data', 'oE');
        if ~exist(save_address, 'dir'), mkdir(save_address); end
        
        for which_data = datasets % 4 data sets
            
            % Tell the current process
            fprintf('Computing E_ori, E_xy, Z for dataset %d\n', which_data);
            
            % Load the stimuli
            fname = sprintf('stimuli-dataset%02d.mat', which_data);
            path=fullfile(stdnormRootPath, 'Data', 'Stimuli', fname);
            load(path, 'stimuli')
            labelVec = 1:size(stimuli, 4);
            
            % Compute energy (E_ori) for models that pool over space
            % (one value per orientation band per stimulus)
            % E_ori = (θ, ep, stim)
            % used in CE and NOA model
            E_ori = cal_oE( stimuli, labelVec, 'orientation', which_data );
            fname = sprintf('E_ori_%02d.mat', which_data);
            save(fullfile(save_address, fname), 'E_ori')
            
            % Compute energy (E_xy) for models that operate on space
            % (one value per spatial position per stimulus)
            % E_xy = (x, y, θ, ep, stim)
            % used in SOC, OTS
            E_xy  = cal_oE( stimuli, labelVec, 'space', which_data );
            fname = sprintf('E_xy_%02d.mat', which_data);
            save(fullfile(save_address, fname), 'E_xy','-v7.3')
            
            % Z normalization for OTS model
            % Z = ( x, y, θ, ep, stim)
            Z = cal_Z( E_xy, labelVec);
            fname = sprintf('Z_%02d.mat', which_data);
            save(fullfile(save_address, fname), 'Z','-v7.3')
            
            clear E_xy
            clear E_mean
            clear Z
        end
        
    case 'S2H4'
        
        % variables
        datasets  = [1, 4];
        rois      = 1:3;
        optimizer = 'fmincon';
        fittime   = 40;
        target    = 'target';
        model     = oriSurroundModel( optimizer, fittime);
        data_folder = 'Cross';
        n_stimuli = 50;
        
        % prediction matrix, NewOldData x datasets x rois x pred
        BOLD_pred = nan( 2, length(datasets), length(rois), n_stimuli);
        BOLD_data = nan( 2, length(datasets), length(rois), n_stimuli);
        for roi = rois
            for ds_idx = 1:length(datasets)
                ds = datasets(ds_idx);
                switch ds
                    case 1
                        target_ind = [ 1:10, 35:38, 47:50];
                    case 2
                        target_ind = [ 1:10, 33:36, 45:48];
                    case {3, 4}
                        target_ind = [ 9:12,    26, 28:39];
                end
                
                % get old prediction
                oE = dataloader( stdnormRootPath, 'oE_xy',...
                    target, ds, roi);
                oZ = dataloader( stdnormRootPath, 'oZ_xy',...
                    target, ds, roi);
                params = dataloader( stdnormRootPath, 'param',...
                    target, ds, roi, data_folder, 5, 'fmincon');
                BOLD_pred( 1, ds_idx, roi, target_ind) = model.predict( model, oE, oZ, params);
                % get new prediction
                BOLD_pred( 2, ds_idx, roi, target_ind) = dataloader( stdnormRootPath, 'BOLD_pred',...
                    target, ds, roi, data_folder, 5, 'fmincon');
                % load human data
                data = dataloader( stdnormRootPath, 'BOLD_target',...
                    target, ds, roi);
                err  = dataloader( stdnormRootPath, 'BOLD_target_error',...
                    target, ds, roi );
                BOLD_data( 1, ds_idx, roi, target_ind) = data;
                BOLD_data( 2, ds_idx, roi, target_ind) = err;
            end
        end
        clear E_xy
        clear Z
        
        figure()
        for roi = rois
            for ds_idx = 1:length(datasets)
                ds = datasets(ds_idx);
                i = (ds_idx-1)*(length(rois)+1)+roi;
                subplot( length(datasets), length(rois)+1, i)
                if (ds==1); len=50; else; len=39; end
                % get data for prediction
                pred = BOLD_pred( :, ds_idx, roi, 1:len);
                data = BOLD_data( 1, ds_idx, roi, 1:len);
                err  = BOLD_data( 2, ds_idx, roi, 1:len);
                % generate plot
                plot_BOLD( pred, data, err, ds, [1,4], target, true);
                if i == length(rois)
                    subplot(length(datasets), length(rois)+1, i+1)
                    plot( 1:2,[nan, nan], '-o',...
                        'MarkerSize', 4.5,...
                        'MarkerEdgeColor', viz.Dark, ...
                        'MarkerFaceColor', viz.Dark,...
                        'LineWidth', 1.5,...
                        'Color', viz.Dark);
                    hold on
                    plot( 1:2,[nan, nan], '-o',...
                        'MarkerSize', 4.5,...
                        'MarkerEdgeColor', viz.Blue, ...
                        'MarkerFaceColor', viz.Blue,...
                        'LineWidth', 1.5,...
                        'Color', viz.Blue);
                    legend({'OLD', 'NEW'}, 'Location', 'East', 'FontSize', 13)
                    axis( 'off' )
                    hold off
                end
            end
        end
        
     % ------------------------ WHY NOA IS WORSE -------------------------%
    case { 'S3H1.1','S3H1.2'}
        
        switch fig
            case 'S3H1.1'
                CEfolder = { 'E_ori', 'oE_ori'};
                paramsfolder = { 'oCross', 'oCross'};
                lg = { 'Old filter', 'New filters' };
                tit = 'Old parameters on new filters and old filters  ';
             case 'S3H1.2'
                CEfolder = { 'E_ori', 'E_ori'};
                paramsfolder = { 'oCross', 'Cross'};
                lg = { 'Old param', 'New param' };
                tit = 'Old & New parameters on new filters';
        end
        
          % variables
        datasets  = [1, 4];
        rois      = 1:3;
        optimizer = 'fmincon';
        fittime   = 40;
        target    = 'target';
        model     = normVarModel( optimizer, fittime);
        n_stimuli = 50;
        
        % prediction matrix, NewOldData x datasets x rois x pred
        BOLD_pred = nan( 2, length(datasets), length(rois), n_stimuli);
        BOLD_data = nan( 2, length(datasets), length(rois), n_stimuli);
        for roi = rois
            for ds_idx = 1:length(datasets)
                ds = datasets(ds_idx);
                switch ds
                    case 1
                        target_ind = [ 1:10, 35:38, 47:50];
                    case 2
                        target_ind = [ 1:10, 33:36, 45:48];
                    case {3, 4}
                        target_ind = [ 9:12,    26, 28:39];
                end
                
                % load new E
                E = dataloader( stdnormRootPath, CEfolder{1},...
                    target, ds, roi);
                % get prediction with old params
                oparams = dataloader( stdnormRootPath, 'param',...
                    target, ds, roi, paramsfolder{1}, 3, 'fmincon');
                BOLD_pred( 1, ds_idx, roi, target_ind) = model.predict( model, E, oparams);
                % get new prediction
                E = dataloader( stdnormRootPath, CEfolder{2},...
                    target, ds, roi);
                params = dataloader( stdnormRootPath, 'param',...
                    target, ds, roi, paramsfolder{2}, 3, 'fmincon');
                BOLD_pred( 2, ds_idx, roi, target_ind) = model.predict( model, E, params);
                % load human data
                data = dataloader( stdnormRootPath, 'BOLD_target',...
                    target, ds, roi);
                err  = dataloader( stdnormRootPath, 'BOLD_target_error',...
                    target, ds, roi );
                BOLD_data( 1, ds_idx, roi, target_ind) = data;
                BOLD_data( 2, ds_idx, roi, target_ind) = err;
            end
        end
        
        figure()
        for roi = rois
            for ds_idx = 1:length(datasets)
                ds = datasets(ds_idx);
                i = (ds_idx-1)*(length(rois)+1)+roi;
                subplot( length(datasets), length(rois)+1, i)
                if (ds==1); len=50; else; len=39; end
                % get data for prediction
                pred = BOLD_pred( :, ds_idx, roi, 1:len);
                data = BOLD_data( 1, ds_idx, roi, 1:len);
                err  = BOLD_data( 2, ds_idx, roi, 1:len);
                % generate plot
                plot_BOLD( pred, data, err, ds, [1,4], target, true);
                if i == length(rois)
                    subplot(length(datasets), length(rois)+1, i+1)
                    plot( 1:2,[nan, nan], '-o',...
                        'MarkerSize', 4.5,...
                        'MarkerEdgeColor', viz.Dark, ...
                        'MarkerFaceColor', viz.Dark,...
                        'LineWidth', 1.5,...
                        'Color', viz.Dark);
                    hold on
                    plot( 1:2,[nan, nan], '-o',...
                        'MarkerSize', 4.5,...
                        'MarkerEdgeColor', viz.Blue, ...
                        'MarkerFaceColor', viz.Blue,...
                        'LineWidth', 1.5,...
                        'Color', viz.Blue);
                    legend(lg, 'Location', 'East', 'FontSize', 13)
                    axis( 'off' )
                    hold off
                end
            end
        end
        sgtitle( tit, 'FontSize', 16)
     
    case {'S3H1.3','S3H1.4'}
        
         % check the density effect
        % dim1: old or new; 2
        % dim2: gratings or snakes; 2
        % dim3: contrast level; 5
        %cls = [ 35, 36, 8, 37, 38; 47, 48, 3, 49, 50];
         % visualize the filters
        colors = [  viz.Red; viz.Blue; viz.Red.*.7; viz.Blue.*.7];
        switch fig; case 'S3H1.3'; group='con'; case 'S3H1.4'; group='den'; end
        cls = getDataCls( ds, group) ;
        E_cls  = cell([2,size(cls)]);
        ep = 5;
        for i=1:size(cls,1)
            for j=1:size(cls,2)
                [E, oE] = idx2CE(cls(i,j), ds, roi, ep);
                E_cls{1,i,j} = squeeze( mean( E, [1,2]));
                E_cls{2,i,j} = squeeze( mean( oE, [1,2]));
            end
        end
        
        % Get NOA normalized energy
        sum_E  = nan([2,size(cls)]);
        sum_Z  = nan([2,size(cls)]);
        sum_D  = nan([2,size(cls)]);
        % get sum E, Z, D
        w = 50;
        figure();
        for i=1:2
            for j=1:size(cls,1)
                for k=1:size(cls,2)
                    E = E_cls{i,j,k};
                    Z = var(E);
                    sum_E(i,j,k) = mean(E(:));
                    sum_Z(i,j,k) = mean(Z(:));
                    D = E.^2 ./ ( 1 + w^2 * Z);
                    sum_D(i,j,k) = mean(D(:));
                end
            end
        end
        % visualize the filters
        sum_vals = { sum_E, sum_Z, sum_D};
        
        titles = {'summed E', 'summed Z', 'S',...
            'scaled summed E', 'scaled summed Z', 'scaled S'};
        for k=1:length(sum_vals)
            x = sum_vals{k};
            subplot( 2, 3, k)
            for j=1:size(x,2)
                l = size(x,3);
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(1,j,:)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', colors(j,:), ...
                    'MarkerFaceColor', colors(j,:),...
                    'LineWidth', 3,...
                    'Color', colors(j,:))
                title( titles{k}, 'FontSize', 14)
                hold on
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(2,j,:)),...
                    '--','LineWidth', 2,...
                    'Color', colors(j+2,:))
                ylim([0, max(x(:))*1.2])
            end
            xticklabels('')
            subplot( 2, 3, k+3)
            for j=1:size(x,2)
                l = size(x,3);
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(1,j,:)./x(1,1,1)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', colors(j,:), ...
                    'MarkerFaceColor', colors(j,:),...
                    'LineWidth', 3,...
                    'Color', colors(j,:))
                title( titles{k+3}, 'FontSize', 14)
                hold on
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(2,j,:)./x(2,1,1)),...
                    '--','LineWidth', 2,...
                    'Color', colors(j+2,:))
            end
            xticklabels('')
            
        end
        sgtitle(sprintf('w=%d',w),'FontSize', 14', 'FontWeight', 'Bold')
        hold off
        
        figure()
        ws = [ .1, 1, 10, 25, 50, 75, 100, 250, 500, 1000];
        g = [ 1, 1];
        n = [ 1, 1];
        sum_D  = nan([2,size(cls),length(ws)]); % oldNew x g-s x lvl x ws
        % get sum E, Z, D
        for wi = 1:length(ws)
            w = ws(wi);
            for i=1:2
                for j=1:size(cls,1)
                    for k=1:size(cls,2)
                        E = E_cls{i,j,k};
                        Z = var(E);
                        D = E.^2 ./ ( 1 + w^2 * Z);
                        x = g(i) .* mean(D, 1).^n(i);
                        sum_D(i,j,k,wi) = mean(x(:));
                    end
                end
            end
        end
       
        x  = sum_D;
        for k=1:length(ws)
            w = ws(k);
            subplot( 2, 5, k)
            for j=1:size(x,2)
                l = size(x,3);
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(sum_D(1,j,:,k)./sum_D(1,1,1,k)),...
                    '-o', 'MarkerSize', 5,...
                    'MarkerEdgeColor', colors(j,:), ...
                    'MarkerFaceColor', colors(j,:),...
                    'LineWidth', 3,...
                    'Color', colors(j,:))
                title( sprintf('w=%.1f', w), 'FontSize', 14)
                hold on
                plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(sum_D(2,j,:,k)./sum_D(2,1,1,k)),...
                    '--','LineWidth', 2,...
                    'Color', colors(j+2,:))
            end
            xticklabels('')
            
        end
        titleStr = sprintf('Scaled s with varied w, DS=%d,V=%d, %s effect', [ds, roi, group]);
        sgtitle( titleStr,'FontSize', 14', 'FontWeight', 'Bold')
        hold off
        
end
end

function F = getOTSFilters( E)
sigma_p=.1;
sigma_g=.85;
sigma_s=.01;
sz = round(size(E, 1) / 20)*2;
F = kernel_weight( sigma_p, sigma_g, sigma_s, sz );
end

function [E, oE]= idx2CE( idx, dataset, roi, ep)

if (nargin < 4), ep = 0; end

filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(dataset);
numpix      = 150;
pixperdeg   = numpix / fov;
ppc         = pixperdeg/filter_cpd; % pixels per cycle
support     = 6; % cycles per filter
o = linspace(0,pi, 9);
thetavec = o(1:end-1);
nO=length(thetavec);
padsize = ppc * support;
nX = numpix + padsize*2;

S = dataloader( stdnormRootPath, 'stimuli', 'all', dataset, roi);

if ep
        epvec = ep;
        E = nan(nX, nX, nO, length(epvec));
        oE = nan(nX, nX, nO, length(epvec));
else 
        epvec = 1:9;
        E = nan(nX, nX, nO, 9);
        oE = nan(nX, nX, nO, 9);
end
    for i=1:length(epvec)
        iep = epvec(i);
        s = S( :, :, iep, idx);
        padstimulus=zeros(nX, nX);
        padstimulus(padsize+(1:numpix),padsize+(1:numpix))=s;
        s=padstimulus;

        % Get filters
        [ Gabor_c, Gabor_s]=getFilters( 'new', dataset);
        [ oGabor_c, oGabor_s] = getFilters( 'old', dataset);

        % Get contrast energy
        e = squeeze(Icontrast(s, Gabor_c, Gabor_s, ppc, thetavec));
        oe = squeeze(Icontrast(s, oGabor_c, oGabor_s, ppc, thetavec));

        % add to the matrix
        E( :, :, :, i) = e;
        oE( :, :, :, i) = oe;
    end
    
    E = squeeze(E);
    oE = squeeze(oE);
end

function cls = getDataCls(ds, group )
switch ds
    case 1
        switch group
            case 'den'
                cls = [ 1, 2, 3, 4, 5; 6, 7, 8, 9, 10];
            case 'con'
                cls = [ 47, 48, 3, 49, 50; 35, 36, 8, 37, 38];
            case 'tar'
                cls = [ 1, 2, 3, 4, 5;...
                    6, 7, 8, 9, 10; ...
                    47, 48, 3, 49, 50;...
                    35, 36, 8, 37, 38];
        end
    case 2
        switch group
            case 'den'
                cls = [ 1, 2, 3, 4, 5;6, 7, 8, 9, 10];
            case 'con'
                cls = [ 45, 46, 2, 47, 48; 33, 34, 7, 35, 36];
            case 'tar'
                cls = [ 1, 2, 3, 4, 5;...
                    6, 7, 8, 9, 10;...
                    45, 46, 2, 47, 48;...
                    33, 34, 7, 35, 36];
        end
    case {3,4}
        switch group
            case 'den'
                cls = [ 39, 38, 37, 36; 26, 27, 28, 29];
            case 'con'
                cls = [ 34, 33, 32, 31; 9, 10, 11, 12];
            case 'tar'
                cls = [ 39, 38, 37, 36;...
                    26, 27, 28, 29;...
                    34, 33, 32, 31;...
                    9, 10, 11, 12 ];
        end
end
end

function [ Gabor_c, Gabor_s] =getFilters( mode, dataset)
filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(dataset);
numpix      = 150;
pixperdeg   = numpix / fov;
ppc         = pixperdeg/filter_cpd; % pixels per cycle
support     = 6; % cycles per filter
o = linspace(0,pi, 9);
thetavec = o(1:end-1);
% Get filters
switch  mode
    case 'new'
        [ Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);
    case 'old'
        [ Gabor_c, Gabor_s] = makeOldFilter(ppc, thetavec, support);
end
end

function E = cal_oE( data, labelVec, mode, which_data)

filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(which_data);
numpix      = size(data,1);
pixperdeg   = numpix / fov;
ppc         = pixperdeg/filter_cpd; % pixels per cycle
support     = 6; % cycles per filter

o = linspace(0,pi, 9);
thetavec = o(1:end-1);
nO=length(thetavec);

[ Gabor_c, Gabor_s]=makeOldFilter(ppc, thetavec, support);

padsize = ppc * support;
sz = numpix + padsize*2;

switch mode
    case 'orientation'
        E = zeros(nO, 9, length(labelVec));
    case 'space'
        E = nan( sz, sz, nO, 9, length( labelVec ) );
end

idx = round((1:10)/10*length(labelVec));

fprintf('\n');
for ii= 1:length(labelVec)
    if ismember(ii, idx), fprintf('.'); end
    
    label = labelVec(ii);
    
    for ep = 1 : 9 % Each have 9 examples.
        
        stimulus = data( : , : , ep , label );
        
        %Pad the stimulus to avoid edge effect
        padstimulus=zeros(numpix + padsize*2, numpix + padsize*2);
        padstimulus(padsize+(1:numpix),padsize+(1:numpix))=stimulus;
        stimulus=padstimulus;
        
        % Filtering and rectification to get the CONTRAST of the image
        con = squeeze(Icontrast(stimulus, Gabor_c, Gabor_s, ppc, thetavec)); %3 - D x , y , theta
        
        if strcmpi( mode, 'orientation' )
            
            % Create a disk-like weight to prevent edge effect
            w = gen_disk( size( con ,  1 ));  %3 - D x , y , theta
            
            % Calculate E_ori for orientation-type model
            % Sum over space
            E_ori = squeeze(mean(mean(w.*con , 2 ), 1)); % 1- D theta
            
            % Store the data into a matrix
            E( : ,  ep , ii ) = E_ori';
            
        elseif strcmp( mode, 'space' )
            % Calculate E_space for space-type model
            % Assign the data into a matrix
            E( : , : , : , ep , ii ) = con;
            
        end
    end
end
fprintf('\n');


end

