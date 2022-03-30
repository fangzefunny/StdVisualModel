function []=revisitOTS(fig)

% Some variables
dataset     = 1;
roi         = 1;
ep          = 5;
Blue        = [   9, 132, 227] / 255;
Green       = [   0, 184, 148] / 255;
Red         = [ 255, 118, 117] / 255;
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
S_gra = S( :, :, ep, 8);
S_sna = S( :, :, ep, 3);

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
cls = [ 6, 7, 8, 9, 10; 1, 2, 3, 4, 5];
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
        
    case 'contrastEnergy'
        
        
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
        
    case 'normalizedEnergy'
        
        % get normalized energy
        ws = logspace( .1, 6, 10);
        rats = nan(length(ws), 4);
        for i = 1:length(ws)
            w = ws(i);
            D_gra  = E_gra ./ (1+ w*Z_gra);
            rats(i,1) = 1;
            D_sna  = E_sna ./ (1+ w*Z_sna);
            rats(i,2) = sum(D_sna(:)) / sum(D_gra(:));
            oD_gra = oE_gra ./ (1+ w*oZ_gra);
            rats(i,3) = sum(oD_gra(:)) / sum(D_gra(:));
            oD_sna = oE_sna ./ (1+ w*oZ_sna);
            rats(i,4) = sum(oD_sna(:)) / sum(D_gra(:));
            
        end
        
        % for orientation energy figure
        figure();
        subplot(1,2,1)
        z_stats = nan(2,4);
        Zs = { Z_gra, Z_sna, oZ_gra, oZ_sna};
        for i = 1:4
            z = Zs{i};
            z_stats(1,i) = mean( z(:));
            z_stats(2,i) = std( z(:));
        end
        colors = [ Blue; Red; Blue.*.7; Red.*.7];
        hold on
        for i = 1:4
            bar( i, z_stats(1,i),...
                'FaceColor', colors(i,:),...
                'EdgeColor', colors(i,:));
        end
        er = errorbar( 1:4, z_stats(1,:), ...
            (z_stats(2,:)), ...
            (z_stats(2,:)));
        er.Color = [ 0, 0, 0];
        er.LineStyle = 'none';
        xticks([ 1, 2, 3, 4])
        xticklabels({'Gratings','Snakes', 'Old gratings','Old snakes'})
        xtickangle(45)
        ylabel( 'Z value','FontSize', 16)
        hold off
        subplot(1,2,2)
        sna2gra = horzcat( rats(:,2), rats(:,4)./rats(:,3));
        b1 = bar(sna2gra);
        b1(1).FaceColor = Grey;
        b1(1).EdgeColor = Grey;
        b1(2).FaceColor = Grey .* .7;
        b1(2).EdgeColor = Grey .* .7;
        xlabel( 'w value','FontSize', 16)
        xticklabels( num2str(ws', '%.2f'))
        xtickangle(45)
        ylabel( 'Snakes to gratings','FontSize', 16)
        legend( 'New', 'Old')
        title( 'Vary the parameter w','FontSize', 16);
        ylim([0, 1.6])
        
    case 'contrastEffect'
        
        
        sum_E  = nan([2,size(cls)]);
        sum_Z  = nan([2,size(cls)]);
        sum_D  = nan([2,size(cls)]);
        % get sum E, Z, D
        w = 150;
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
        titles = {'E', 'Z', 'D',...
                  'scaled E', 'scaled Z', 'scaled D'};
        for k=1:length(sum_vals)
            x = sum_vals{k};
            subplot( 2, 3, k)
            for j=1:size(x,2)
                l = size(x,3);
               bar((j-1)*(l+1)+1:j*(l+1)-1,squeeze(x(1,j,:)),...
                    'FaceColor', colors(j,:),...
                    'EdgeColor', colors(j,:))
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
        hold off
end

    function [E, oE]= idx2CE( idx)
        
        dataset     = 1;
        roi         = 1;
        ep          = 5;
        filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
        fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
        fov         = fovs(dataset);
        numpix      = 150;
        pixperdeg   = numpix / fov;
        ppc         = pixperdeg/filter_cpd; % pixels per cycle
        support     = 6; % cycles per filter
        o = linspace(0,pi, 9);
        thetavec = o(1:end-1);
        
        S = dataloader( stdnormRootPath, 'stimuli', 'all', dataset, roi);
        s = S( :, :, ep, idx);
        
        % Get filters
        [ Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);
        [ oGabor_c, oGabor_s] = makeOldFilter(ppc, thetavec, support);
        
        % Get contrast energy
        E = squeeze(Icontrast(s, Gabor_c, Gabor_s, ppc, thetavec));
        oE = squeeze(Icontrast(s, oGabor_c, oGabor_s, ppc, thetavec));
        
    end


end

