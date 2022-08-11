classdef contrastModel
    
    % The basic properties of the class
    properties
        optimizer
        fittime
        num_param    = 2
        fparam_name  = {'g', 'alpha'}
        param_name   = {'g', 'alpha'}
        param_bound  = []
        param_pbound = []
        param        = []
        model_idx    = 1;
        model_type   = 'orientation'
        legend       = 'CE'
        loss_log     = []
    end
    
    methods
        
        % init the model
        function model = contrastModel(optimizer, fittime, param_bound, param_pbound)
            
            % pbound is possible bound, used to init the parameters
            % bound is the real bound of the parameters
            if (nargin < 4), param_pbound = [   1,  10;  -20,  20]; end
            if (nargin < 3), param_bound  = [-inf, inf; -inf, inf]; end
            if (nargin < 2), fittime = 40; end
            if (nargin < 1), optimizer = 'fmincon';end
            if size(param_bound,1) ~= model.num_param
                disp('Wrong Bound')
            elseif size(param_pbound, 1) ~= model.num_param
                disp('Wrong Possible Bound')
            end
            
            model.param_bound  = param_bound;
            model.param_pbound = param_pbound;
            model.fittime      = fittime;
            model.optimizer    = optimizer;
        end
    end
    
    methods (Static = true)
        
        % the core model function
        function y_hat = forward(model, x, param)
            
            % upack the input
            e = x{1};
            
            % get the parameters
            g = param(1);
            alpha = Sigmoid(param(2));
            
            % d: ori x exp x stim
            d = e;
            
            % mean over orientation, s: exp x stim
            s = mean(d, 1);
            
            % add gain and exponential, yi_hat: exp x stim
            yi_hat = g .* s .^ alpha;
            
            % mean over different examples, y_hat: stim
            y_hat = squeeze(mean(yi_hat, 2))';
            
        end
        
        % print the raw parameters, used in s3
        function param = print_fparam(model, param)
            % reshape
            param = reshape(param, model.num_param, []);
            % set param
            param(2, :) = Sigmoid(param(2, :));
        end
        
        % print reparameterized parameters, used in s3
        function param = print_param(model, param)
            param = model.print_fparam(model, param);
        end
        
        % measure the goodness of
        function R2 = metric(pred, tar)
            
            % sse of the benchmark, mean
            sse_mean = sum((tar - mean(tar)).^2);
            % sse of the model
            sse_model = sum((tar - pred).^2);
            % R2: the variance reduction performance relative
            %     to the benchmark
            R2 = 1 -  sse_model / sse_mean;
            
        end
        
        % measure the mse
        function loss = rmse(pred, tar)
            % rooted mean square error
            loss = double(sqrt(mean((pred - tar).^2)));
        end
        
        
        % Loss function for optimization: mean squared error
        function mse = loss_fn(param, model, x, y_tar)
            
            % predict y_hat: 1 x stim
            y_hat = model.forward(model, x, param);
            
            % cal mse; squeeze the matrix into a scalar
            mse = double(mean((y_tar - y_hat).^2));
        end
        
        % Fit the data
        function [loss, param, loss_history] = optim(model, x, BOLD_tar, verbose)
            
            % set up the loss function
            func=@(z) model.loss_fn(z, model, x, BOLD_tar);
            
            % set up the bound
            lb  = model.param_bound(:, 1);
            ub  = model.param_bound(:, 2);
            plb = model.param_pbound(:, 1);
            pub = model.param_pbound(:, 2);
            
            % init param using possible bound
            x0_set = (plb + (pub - plb) .* rand(model.num_param, model.fittime))';
            
            % storage
            x_opt = nan(model.fittime, model.num_param);
            mse = nan(model.fittime, 1);
            
            % fit with n init
            tStart = tic;
            for ii = 1:model.fittime
                
                % optimization
                switch model.optimizer
                    case 'bads'
                        [x_opt(ii, :), mse(ii)] = bads(func, x0_set(ii, :), lb', ub', plb', pub', [], opts);
                    case 'fmincon'
                        opts = optimoptions('fmincon', 'Display', verbose); %, 'Algorithm', 'sqp'
                        [x_opt(ii, :), mse(ii)] = fmincon( func, x0_set(ii, :), [], [], [], [], lb', ub', [], opts);
                end
                
                fprintf('   fit: %d, progress: %.2f, loss: %.4f \n', ii, ii/model.fittime, mse(ii))
            end
            
            % find the lowest mse
            mse(imag(mse) ~= 0) = inf; % find the imag number and set to inf
            loss  = min(mse);
            trial = find(mse == loss);
            param = x_opt(trial(1), :);
            loss_history = mse;
            
            tEnd = toc(tStart);
            fprintf('opt loss %.4f, elasped timed %.2f\n', loss, tEnd)
            
        end
        
        % fit the data
        function [BOLD_hat, params, R2, model] = fit(model, x, BOLD_tar, verbose, cross_valid, save_info)
            
            switch cross_valid
                
                case 'one'
                    
                    % optimize to find the best
                    [~, param, loss_history] = model.optim(model, x, BOLD_tar, verbose );
                    params = param;
                    loss_histories = loss_history;
                    
                    % predict test data
                    BOLD_hat = model.forward(model, x, param );
                    R2 = model.metric(BOLD_hat, BOLD_tar);
                    model.loss_log = loss_histories;
                    
                case 'cross_valid'
                    
                    % achieve stim vector
                    E = x{1};
                    stim_dim = size(E, length(size(E)));
                    stim_vector = save_info.start_idx : size(E, length(size(E)));
                    
                    % storage, try to load the saved history, if any
                    if save_info.start_idx == 1
                        params   = nan(model.num_param, size(E, stim_dim));
                        BOLD_hat = nan(1, size(E, stim_dim));
                    else
                        load(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                            save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        load(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
                            save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_hat');
                    end
                    
                    % cross_valid
                    for knock_idx = stim_vector
                        fprintf('fold %d \n', knock_idx)
                        
                        % train vector and train data
                        keep_idx = setdiff(stim_vector, knock_idx);
                        E_train  = E(:, :, keep_idx);
                        target_train = BOLD_tar(keep_idx);
                        E_test   = E(:, :, knock_idx);
                        
                        % fit the training data
                        x_train = {E_train}; x_test = {E_test};
                        [~, param] = model.optim(model, x_train, target_train, verbose);
                        params(:, knock_idx) = param;
                        
                        % predict test data
                        BOLD_hat(knock_idx) = model.forward(model, x_test, param);
                        
                        % save files for each cross validated fold
                        save(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                            save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        save(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
                            save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_hat');
                    end
                    
                    % evaluate performance of the algorithm on test data
                    R2 = model.metric(BOLD_hat, BOLD_tar);
            end
        end
    end
end
