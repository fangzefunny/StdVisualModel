function []=revisitOTS(fig, dataset, roi, group)

% Some variables
switch dataset
    case 1
        switch group
            case 'den'
                cls = [ 6, 7, 8, 9, 10; 1, 2, 3, 4, 5];
            case 'con'
                cls = [ 35, 36, 8, 37, 38; 47, 48, 3, 49, 50];
            case 'tar'
                cls = [ 1, 2, 3, 4, 5;...
                    6, 7, 8, 9, 10; ...
                    47, 48, 3, 49, 50;...
                    35, 36, 8, 37, 38];
        end
    case 2
        switch group
            case 'den'
                cls = [ 6, 7, 8, 9, 10; 1, 2, 3, 4, 5];
            case 'con'
                cls = [ 33, 34, 7, 35, 36; 45, 46, 2, 47, 48];
            case 'tar'
                cls = [ 1, 2, 3, 4, 5;...
                    6, 7, 8, 9, 10;...
                    45, 46, 2, 47, 48;...
                    33, 34, 7, 35, 36];
        end
    case {3,4}
        switch group
            case 'den'
                cls = [ 26, 27, 28, 29; 39, 38, 37, 36];
            case 'con'
                cls = [ 9, 10, 11, 12; 34, 33, 32, 31];
            case 'tar'
                cls = [ 39, 38, 37, 36;...
                    26, 27, 28, 29;...
                    34, 33, 32, 31;...
                    9, 10, 11, 12 ];
        end
end
ep          = 5;
Blue        = [   9, 132, 227] / 255;
Dark        = [  52,  73,  94] ./ 255;
Green       = [   0, 184, 148] / 255;
Red         = [ 255, 118, 117] / 255 .* .8;
Yellow      = [ 253, 203, 110] / 255;
Grey        = [ .7, .7, .7];
filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(dataset);
numpix      = 150;
pixperdeg   = numpix / fov;
ppc         = pixperdeg/filter_cpd; % pixels per cycle
support     = 6; % cycles per filter
o = linspace(0,pi, 9);
thetavec = o(1:end-1);

% Get stimuli
S = dataloader( stdnormRootPath, 'stimuli', 'all', dataset, roi);
S_gra = S( :, :, ep, 3);
S_sna = S( :, :, ep, 8);

% Get filters
[ Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);
[ oGabor_c, oGabor_s] = makeOldFilter(ppc, thetavec, support);

% Get contrast energy
E_gra = squeeze(Icontrast(S_gra, Gabor_c, Gabor_s, ppc, thetavec));
E_sna = squeeze(Icontrast(S_sna, Gabor_c, Gabor_s, ppc, thetavec));
oE_gra = squeeze(Icontrast(S_gra, oGabor_c, oGabor_s, ppc, thetavec));
oE_sna = squeeze(Icontrast(S_sna, oGabor_c, oGabor_s, ppc, thetavec));

% check the sum CE at different orientations
Eori_gra = squeeze(mean(E_gra,[1,2]));
Eori_sna = squeeze(mean(E_sna,[1,2]));
oEori_gra = squeeze(mean(oE_gra,[1,2]));
oEori_sna = squeeze(mean(oE_sna,[1,2]));

% Get OTS normalized energy
% get filters
sigma_p=.1;
sigma_g=.85;
sigma_s=.01;
sz = round(size(E_gra, 1) / 20)*2;
F = kernel_weight( sigma_p, sigma_g, sigma_s, sz );
% get normalizer
Z_gra  = calc_z( E_gra, F);
Z_sna  = calc_z( E_sna, F);
oZ_gra = calc_z( oE_gra, F);
oZ_sna = calc_z( oE_sna, F);

% check the contrast effect
% dim1: old or new; 2
% dim2: gratings or snakes; 2
% dim3: contrast level; 5
%cls = [ 35, 36, 8, 37, 38; 47, 48, 3, 49, 50];

E_cls  = cell([2,size(cls)]);

for i=1:size(cls,1)
    for j=1:size(cls,2)
        [E, oE] = idx2CE(cls(i,j));
        E_cls{1,i,j} = E;
        E_cls{2,i,j} = oE;
    end
end

switch fig
    case 'GaborFilter'
        
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
        
    case 'Example'
        
        % for orientation energy figure
        figure();
        Eori_g = horzcat( Eori_gra, oEori_gra);
        Eori_s = horzcat( Eori_sna, oEori_sna);
        subplot( 2, 2, 1)
        b1 = bar(Eori_g);
        Eori_g_rat = Eori_gra ./ oEori_gra;
        text(1:length(Eori_g_rat),oEori_gra, num2str(Eori_g_rat,'%.2f'),...
            'vert','bottom','horiz','center','FontSize', 8);
        b1(1).FaceColor = Blue;
        b1(1).EdgeColor = Blue;
        b1(2).FaceColor = Blue .* .7;
        b1(2).EdgeColor = Blue .* .7;
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
        b2(1).FaceColor = Red;
        b2(1).EdgeColor = Red;
        b2(2).FaceColor = Red .* .7;
        b2(2).EdgeColor = Red .* .7;
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
        b3(1).FaceColor = Grey;
        b3(1).EdgeColor = Grey;
        b3(2).FaceColor = Grey.* .7;
        b3(2).EdgeColor = Grey.* .7;
        ylabel( 'Averaged contrast energy','FontSize', 12)
        legend( 'New', 'Old','FontSize', 12)
        title( 'Sum over orientation');
        xticks([ 1, 2])
        xticklabels({'Gratings','Snakes'})
        
    case 'Effect'
        
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
        colors = [ Blue; Red; Blue.*.7; Red.*.7];
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
        colors = [ Blue; Red; Blue.*.7; Red.*.7];
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
        sgtitle(sprintf('Scaled s with varied w, DS=%d,V=%d', [dataset, roi]),'FontSize', 14', 'FontWeight', 'Bold')
        hold off
        
    case 'bestParams'
        
        target = dataloader( stdnormRootPath, 'BOLD_target', 'all', dataset, roi);
        params = exp([ 10.27, 20.16, 0.7706; 10.27, 20.16, 0.7706]);
        x = nan([3,size(cls)]);
        x(3,:,:) = target(cls);
        m = oriSurroundModel( 'fmincon', 1);
        height = size(E,1);
        m = m.disk_weight( m, height);
        for i=1:2
            for j=1:size(cls,1)
                for k=1:size(cls,2)
                    E = E_cls{i,j,k};
                    Z = calc_z( E, F);
                    D = E ./ ( 1 + params(i,1) * Z);
                    D = bsxfun( @times, D, m.receptive_weight);
                    x(i,j,k) = mean(params(i,2) .* mean(D, [1,2,3]).^params(i,3));
                end
                
            end
        end
        
        % show predictions
        figure()
        colors = [ Red; Blue; Red; Blue; Red.*.7; Blue.*.7; Red.*.7; Blue.*.7];
        for j=1:size(x,2)
            l = size(x,3);
            data = bar((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(3,j,:)),...
                'FaceColor', Grey,...
                'EdgeColor', Grey);
            hold on
            new = plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(1,j,:)),...
                '-o', 'MarkerSize', 5,...
                'MarkerEdgeColor', colors(j,:), ...
                'MarkerFaceColor', colors(j,:),...
                'LineWidth', 3,...
                'Color', colors(j,:));
            hold on
            old = plot((j-1)*(l+1)+1:j*(l+1)-1, squeeze(x(2,j,:)),...
                '--','LineWidth', 2,...
                'Color', colors(j+size(x,2),:));
        end
        legend( [data,new,old], {'data','new','old'}, 'FontSize', 13)
        xticklabels('')
        hold off
        
    case 'preOlddata'
        
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
        
    case 'H4'
        
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
                    'MarkerEdgeColor', Dark, ...
                    'MarkerFaceColor', Dark,...
                    'LineWidth', 1.5,...
                    'Color', Dark);
                hold on
                plot( 1:2,[nan, nan], '-o',... 
                    'MarkerSize', 4.5,...
                    'MarkerEdgeColor', Blue, ...
                    'MarkerFaceColor', Blue,...
                    'LineWidth', 1.5,...
                    'Color', Blue);
               legend({'OLD', 'NEW'}, 'Location', 'East', 'FontSize', 13)
               axis( 'off' )
               hold off 
            end
            end
        end
end


    function [E, oE]= idx2CE( idx)
        
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
        E = nan(nX, nX, nO, 9);
        oE = nan(nX, nX, nO, 9);
        for iep=1:9
            s = S( :, :, iep, idx);
            padstimulus=zeros(nX, nX);
            padstimulus(padsize+(1:numpix),padsize+(1:numpix))=s;
            s=padstimulus;
            
            % Get filters
            [ Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);
            [ oGabor_c, oGabor_s] = makeOldFilter(ppc, thetavec, support);
            
            % Get contrast energy
            e = squeeze(Icontrast(s, Gabor_c, Gabor_s, ppc, thetavec));
            oe = squeeze(Icontrast(s, oGabor_c, oGabor_s, ppc, thetavec));
            
            % add to the matrix
            E( :, :, :, iep) = e;
            oE( :, :, :, iep) = oe;
        end
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

