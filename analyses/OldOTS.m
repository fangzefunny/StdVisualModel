function [a1, a2] = OldOTS(f_idx, ds, roi, n_fix)
%{
    Investigate different normalization fitlers

    Args:
        f_idx: what to do
        ds: data set
        roi: visual cortex. 1, 2, 3
%}
% get the default value
if (nargin < 4), n_fix = false; end
if (nargin < 3), roi = 2; end
if (nargin < 2), ds = 1; end

a1=nan;a2=nan;

switch f_idx
    
    case {'old_lossLand_fine', 'old_lossLand_coarse'}
        
        w_con = exp(6); wcon_unfound = true;
        g_con = exp(5.5); gcon_unfound = true;
        
        switch ds
            case 1
                switch roi
                    case 1; w_opt = 51.205; g_opt = 244.685; n_opt = 1.241;
                    case 2; w_opt = 128.89; g_opt = 244.685; n_opt = 1.015;
                    case 3; w_opt = 192.39; g_opt = 244.062; n_opt = 0.933;
                end
            case 4
                switch roi
                    case 1; w_opt = 113.755; g_opt = 244.691; n_opt = 0.924;
                    case 2; w_opt = 157.498; g_opt = 244.691; n_opt = 0.892;
                    case 3; w_opt = 177.096; g_opt = 244.690; n_opt = 0.842;
                end
        end
        
        if n_fix; n_opt = n_fix; end
        
        switch f_idx
            
            case 'old_lossLand_fine'
                
                nW = 20; nG = nW; sp=3;
                w_Lst = linspace(w_opt*.92, w_opt*1.08, nW);
                g_Lst = linspace(g_opt*.92, g_opt*1.08, nG);
                
            case 'old_lossLand_coarse'
                
                nW = 40; nG = nW; sp=6;
                w_Lst = linspace(w_opt*.3, w_opt*1.7, nW);
                g_Lst = linspace(g_opt*.3, g_opt*1.7, nG);
        end
        
        oE = dataloader(stdnormRootPath, 'oE_xy', 'target', ds, roi);
        oZ = dataloader(stdnormRootPath, 'oZ_xy', 'target', ds, roi);
        y_tar = dataloader(stdnormRootPath, 'BOLD_target',...
            'target', ds, roi);
        model = oOTS('fmincon', 1);
        
        model = model.disk_weight(model, size(oE, 1));
        w_unfound = true; g_unfound = true;
        
        loss_mat = nan(nW, nG);
        
        for i = 1:nW
            for j = 1:nG
                param = [w_Lst(i), g_Lst(j), n_opt];
                y_hat = model.forward(model, oE, oZ, param);
                square_error = (y_tar - y_hat).^2;
                loss_mat(i,j) = double(mean(square_error));
                if w_unfound
                    if (w_Lst(i) <= w_opt) && (w_opt< w_Lst(i+1))
                        w_loc = i;
                        w_unfound = false;
                    end
                end
                if wcon_unfound
                    if i+1 <= nW
                        if (w_Lst(i) <= w_con) && (w_con< w_Lst(i+1))
                            wcon_loc = i;
                            wcon_unfound = false;
                        end
                    else
                        wcon_loc = i;
                        wcon_unfound = false;
                    end
                end
                if g_unfound
                    if (g_Lst(j) <= g_opt) && (g_opt< g_Lst(j+1))
                        g_loc = j;
                        g_unfound = false;
                    end
                end
                if gcon_unfound
                    if j+1 <= nG
                        if (g_Lst(j) <= g_con) && (g_con< g_Lst(j+1))
                            gcon_loc = j;
                            gcon_unfound = false;
                        end
                    else
                        gcon_loc = j;
                        gcon_unfound = false;
                    end
                end
                
            end
        end
        
        param_opt = [w_opt, g_opt, n_opt];
        y_hat = model.forward(model, oE, oZ, param_opt);
        square_error = (y_tar - y_hat).^2;
        disp('The fit loss is:')
        loss_fit = double(mean(square_error))
        
        loss_con = loss_mat(1:wcon_loc, 1:gcon_loc);
        [loss_min_con, n] = min(loss_con(:));
        disp('The lowest (grid) loss within constraint:')
        loss_min_con
        [y_min_con, x_min_con] = ind2sub(size(loss_mat),n);
        
        
        [loss_min_global, n] = min(loss_mat(:));
        disp('The lowest (grid) loss:')
        loss_min_global
        [y_min, x_min] = ind2sub(size(loss_mat),n);
        
        figure();
        imagesc(clip(loss_mat, 0,loss_fit*1.25));
        set(gca,'YDir','normal')
        colormap bone;
        colorbar;
        xticks(1:sp:nG)
        xticklabels(g_Lst(1:sp:nG))
        yticks(1:sp:nW)
        yticklabels(w_Lst(1:sp:nW))
        xlabel('g')
        ylabel('w')
        axis equal;
        hold on
        scatter(g_loc, w_loc, 'MarkerEdgeColor',[1, 0, 0],...
            'MarkerFaceColor',[1, 0, 0],...
            'LineWidth',1.5)
        scatter(x_min, y_min, 80, [1,1,1], 'x')
        scatter(x_min_con, y_min_con, 80, [1,1,1], 'x')
        if gcon_loc < nG; xline(gcon_loc,'Color','red','LineStyle','--');end
        if wcon_loc < nW; yline(wcon_loc,'Color','red','LineStyle','--');end
        
    case {'remove_redundacy_linspace', 'remove_redundacy_logspace', 'OTS_v3_lossLand', 'OTS_classic_lossLand'}
        
        switch f_idx
            
            case 'remove_redundacy_linspace'
                
                nW = 20; nG = nW; sp=6;
                w_Lst = linspace(.03, .6, nW);
                g_Lst = linspace(5e-8, 1e-5, nG);
                %g_Lst = logspace(-7, -2, nG);
            
            case 'remove_redundacy_logspace'
                
                nW = 20; nG = nW; sp=6;
                w_Lst = linspace(.03, .6, nW);
                %g_Lst = linspace(5e-8, 1e-5, nG);
                g_Lst = logspace(-7, -2, nG);
                
            case 'OTS_v3_lossLand'
                
                nW = 40; nG = nW; sp=6;
                w_Lst = linspace(1, 1000, nW);
                g_Lst = linspace(1, 1000, nG);
                
            case 'OTS_classic_lossLand'
                
                nW = 40; nG = nW; sp=6;
                w_Lst = linspace(1e-5, 1e-4, nW);
                g_Lst = linspace(1e-1, 5, nG);
        end
        
        if n_fix; n_opt = n_fix; end
        
        E = dataloader(stdnormRootPath, 'E_xy', 'target', ds, roi);
        Z = dataloader(stdnormRootPath, 'Z_xy', 'target', ds, roi);
        y_tar = dataloader(stdnormRootPath, 'BOLD_target',...
            'target', ds, roi);
        model = oOTS('fmincon', 1);
        model = model.disk_weight(model, size(E, 1));
        
        loss_mat = nan(nW, nG);
        
        for i = 1:nW
            for j = 1:nG
                param = [w_Lst(i), g_Lst(j), n_opt];
                switch f_idx
                    case {'remove_redundacy_linspace', 'remove_redundacy_logspace'}
                         y_hat = model.forward2(model, E, Z, param);
                    case 'OTS_v3_lossLand'
                         y_hat = model.forward(model, E, Z, param);
                    case 'OTS_classic_lossLand'
                         y_hat = model.forwardClassic(model, E, Z, param);
                end
               
                square_error = (y_tar - y_hat).^2;
                loss_mat(i,j) = double(mean(square_error));
                
            end
        end
        
        [loss_min_global, n] = min(loss_mat(:));
        disp('The lowest (grid) loss:')
        loss_min_global
        [y_min, x_min] = ind2sub(size(loss_mat),n);
        
        figure();
        imagesc(clip(loss_mat, 0, loss_min_global*1.25));
        set(gca,'YDir','normal')
        colormap bone;
        colorbar;
        xticks(1:sp:nG)
        xticklabels(g_Lst(1:sp:nG))
        yticks(1:sp:nW)
        yticklabels(w_Lst(1:sp:nW))
        xlabel('g')
        ylabel('w')
        axis equal;
        hold on
        scatter(x_min, y_min, 80, [1,1,1], 'x')
        
end
end

function y = clip(x,bl,bu)
% return bounded value clipped between bl and bu
y=min(max(x,bl),bu);
end
