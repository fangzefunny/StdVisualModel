function CleanUp(fig, ds, roi, group, ns, ws, rescale)
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
if (nargin < 7), rescale = 'avg'; end
if (nargin < 6), ws = [.1, 1, 10, 100, 1000]; end
if (nargin < 5), ns = [-5, -1, 0, 1, 5]; end
if (nargin < 4), group = 'tar'; end
if (nargin < 3), roi = 2; end
if (nargin < 2), ds = 1; end

% get target indices
ind = getDataCls(ds, group);

% get data
BOLD_all = dataloader(stdnormRootPath, 'BOLD_target',...
    'all', ds, roi);
BOLD_err  = dataloader(stdnormRootPath, 'BOLD_target_error',...
    'all', ds, roi );
BOLD_tar = dataloader(stdnormRootPath, 'BOLD_target',...
    'target', ds, roi);


% get some vals
n_sample = 5;


% get model index
[lbvec, emo, model, m_idx] = get_config(ds, fig);

% get E
E = dataloader(stdnormRootPath, emo,...
    'target', ds, roi);

switch fig
    case 'CE'
        % get storage
        BOLD_pred = nan(n_sample, length(lbvec));
        r2s       = nan(n_sample);
        
        % prepare for simulation
        param = [1, 1];
        for i = 1:n_sample
            param(2) = ns(i);
            [BOLD_hat, r2] = get_pred(model, E, param, BOLD_tar, rescale);
            BOLD_pred(i,ind) = BOLD_hat;
            r2s(i) = r2;
        end
        
        % visualize
        figure()
        for i = 1:n_sample
            param(2) = ns(i);
            [~, n] = model.get_param(model, param);
            subplot(1, n_sample, i)
            plot_BOLD(BOLD_pred(i,:), BOLD_all, BOLD_err,...
                ds, m_idx, 'target', true);
            title(sprintf('r2=%.2f\nn=%.3f', r2s(i), n))
        end
    case {'NOA', 'SOC' 'OTS'}
        % get storage
        BOLD_pred = nan(n_sample, n_sample, length(lbvec));
        r2s  = nan(n_sample, n_sample);
        
        % prepare for simulation
        switch fig
            case 'NOA'; a=ws;
            case 'SOC'; a=cs;
            case 'OTS'; a=ws;
                Z = dataloader(stdnormRootPath, 'Z_xy', 'target', ds, roi);
        end
        param = [1, 1, 1];
        for i = 1:n_sample
            for j = 1:n_sample
                param(1)   = a(i);
                param(end) = ns(j);
                switch fig
                    case {'NOA','SOC'}
                        [BOLD_hat, r2] = get_pred(model, E, param, BOLD_tar, rescale);
                    case 'OTS'
                        [BOLD_hat, r2] = get_pred_Z(model, E, Z, param, BOLD_tar, rescale);
                end
                BOLD_pred(i,j,ind) = BOLD_hat;
                r2s(i,j) = r2;
            end
        end
        
        % visualize
        for i = 1:n_sample
            for j = 1:n_sample
                param(1)   = a(i);
                param(end) = ns(j);
                [w,~,n] = model.get_param(model, param);
                subplot(n_sample, n_sample, (i-1)*n_sample+j)
                plot_BOLD(BOLD_pred(i,j,:), BOLD_all, BOLD_err,...
                    ds, m_idx, 'target', true);
                title(sprintf('r2=%.2f\nw=%.e,n=%.3f', r2s(i,j), w, n))
            end
        end
end
end

function [BOLD_hat, r2] = get_pred(model, E, param, BOLD_tar, rescale)
BOLD_hat = model.forward(model, E, param);
switch rescale 
    case 'first'
        BOLD_hat = BOLD_hat.* (BOLD_tar(1) / BOLD_hat(1));
    case 'avg'
        BOLD_hat = BOLD_hat.* (mean(BOLD_tar(:)) / mean(BOLD_hat(:)));
end
r2 = model.metric(BOLD_hat, BOLD_tar);
end

function [BOLD_hat, r2] = get_pred_Z(model, E, Z, param, BOLD_tar, rescale)
BOLD_hat = model.forward(model, E, Z, param);
switch rescale 
    case 'first'
        BOLD_hat = BOLD_hat.* (BOLD_tar(1) / BOLD_hat(1));
    case 'avg'
        BOLD_hat = BOLD_hat.* (mean(BOLD_tar(:)) / mean(BOLD_hat(:)));
end
r2 = model.metric(BOLD_hat, BOLD_tar);
end

function [lbvec, emo, model, m_idx] = get_config(ds, nam)
switch ds
    case 1; lbvec = 1:50;
    case 2; lbvec = 1:48;
    case {3,4}; lbvec = 1:39;
end
switch nam
    case {'CE','NOA'}; emo='E_ori';
    case {'SOC','OTS'}; emo='E_xy';
end
switch nam
    case 'CE';  model=contrastModel('fmincon',1); m_idx=1;
    case 'NOA'; model=normVarModel('fmincon',1); m_idx=3;
    case 'SOC'; model=SOCModel('fmincon',1); m_idx=4;
    case 'OTS'; model=oriSurroundModel('fmincon',1); m_idx=5;
end
end

function cls = getDataCls(ds, group )
switch ds
    case 1
        switch group
            case 'den'
                cls = [1, 2, 3, 4, 5; 6, 7, 8, 9, 10];
            case 'con'
                cls = [47, 48, 3, 49, 50; 35, 36, 8, 37, 38];
            case 'tar'
                cls = [1:10, 35:38, 47:50];
        end
    case 2
        switch group
            case 'den'
                cls = [1, 2, 3, 4, 5;6, 7, 8, 9, 10];
            case 'con'
                cls = [45, 46, 2, 47, 48; 33, 34, 7, 35, 36];
            case 'tar'
                cls = [1:10, 33:36, 45:48];
        end
    case {3,4}
        switch group
            case 'den'
                cls = [39, 38, 37, 36; 26, 27, 28, 29];
            case 'con'
                cls = [34, 33, 32, 31; 9, 10, 11, 12];
            case 'tar'
                cls = [9:12, 26, 28:39];
        end
end
end
