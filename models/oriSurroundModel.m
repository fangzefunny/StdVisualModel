classdef oriSurroundModel < contrastModel 
    
    % The basic properties of the class
    properties 
    end
    
    methods
        
        % init the model
        function model = oriSurroundModel(optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
            % check the range after fitting non-cross fit 
            if (nargin < 4), param_pbound = [1e-6,  .1;    1,  10;  -20,  20]; end
            if (nargin < 3), param_bound  = [-inf, inf; -inf, inf; -inf, inf]; end
            if (nargin < 2), fittime = 40; end
            if (nargin < 1), optimizer = 'fmincon';end
            
            param_num = 3;
            
            if size(param_bound,1) ~= param_num 
                error('Wrong Bound')
            elseif size(param_pbound, 1) ~= param_num 
                error('Wrong Possible Bound')
            end
            
            model.param_bound  = param_bound;
            model.param_pbound = param_pbound; 
            model.fittime      = fittime;
            model.optimizer    = optimizer; 
            model.num_param    = param_num;
            model.fparam_name  = {'w', 'b', 'alpha'};
            model.param_name   = {'sigma', 'g', 'alpha'};
            model.legend       = 'OTS'; 
            model.model_type   = 'space';
            model.param        = [];
            model.model_idx    = 3;
        end
                       
    end
           
    methods (Static = true)
                    
       % function: f()
        function y_hat = forward(model, E, Z, param)
             
            % get the parameters
            sig = param(1);
            g = param(2);
            alpha = Sigmoid(param(3));
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            d = E ./ (sig + Z); 
            d = squeeze(mean(d, 3));
                        
            % mean over spatial position
            s = squeeze(mean(mean(d , 1), 2)); % ep x stimuli
            
            % add gain and exponential, yi_hat: exp x stim
            yi_hat = g .* s .^ alpha; 

            % mean over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end
        
        % print the raw parameters, used in s3 
        function param = print_fparam(model, param)          
            % reshape
            param = reshape(param, model.num_param, []);
            % set param
            param(3, :) = Sigmoid(param(3, :));
        end
        
        % print reparameterized parameters, used in s3 
        function param = print_param(model, param)
            % get the raw fitted param
            fparam = model.print_fparam(model, param);
            w = fparam(1, :);
            b = fparam(2, :);
            alpha = fparam(3, :);
            % reparameterize
            param  = NaN(size(fparam, 1), size(fparam, 2));
            param(1, :) = b./w;         % sig 
            param(2, :) = (1/w).^alpha; % gain
            param(3, :) = alpha;        % alpha 
        end
        
        % measure the goodness of 
        function R2 = metric(BOLD_pred, BOLD_tar)
            R2 = metric@contrastModel(BOLD_pred, BOLD_tar);
        end
        
         % measure the goodness of 
        function loss= rmse(BOLD_pred, BOLD_tar)
            loss = rmse@contrastModel(BOLD_pred, BOLD_tar);
        end
        
        % loss function with sum sqaure error: sum(y - y_hat).^2
        function mse = loss_fn(param, model, E, Z, y_tar)
            
            % predict y_hat: 1 x stim 
            y_hat = model.forward(model, E, Z, param);
            % mse 
            mse = double(mean((y_tar - y_hat).^2));
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim(model, E, Z,  BOLD_tar, verbose)
            
           % set up the loss function
            func=@(x) model.loss_fn(x, model, E, Z, BOLD_tar);
            
            % set up the bound
            lb  = model.param_bound(:, 1);
            ub  = model.param_bound(:, 2);
            plb = model.param_pbound(:, 1);
            pub = model.param_pbound(:, 2);
            
            % init param
            x0_set = (plb + (pub - plb) .* rand(model.num_param, model.fittime))';
            
            % storage
            x   = NaN(model.fittime, model.num_param);
            mse = NaN(model.fittime, 1);
            
            % fit with n init
            for ii = 1:model.fittime
                
                % optimization
                switch model.optimizer
                    case 'bads'
                        [x(ii, :), mse(ii)] = bads(func, x0_set(ii, :), lb', ub', plb', pub', [], opts);
                    case 'fmincon'
                        opts = optimoptions('fmincon', 'Display', verbose, 'Algorithm', 'sqp');
                        [x(ii, :), mse(ii)] = fmincon(func, x0_set(ii, :), [], [], [], [], lb', ub', [], opts);
                end
                
                fprintf('   fit: %d, loss: %.4f \n', ii, mse(ii)) 
            end
            
            % find the lowest mse
            mse(imag(mse) ~= 0) = inf; % find the imag number and set to inf
            loss  = min(mse);
            trial = find(mse == loss);
            param = x(trial(1), :); 
            loss_history = mse;
            
        end
        
        % Predict the BOLD response: y_hat = f(x)
        function BOLD_hat = predict(model, E, Z, params, if_cross)
            
            if (nargin < 5), if_cross='cross_valid'; end
            
            switch if_cross
            
                case 'one'
                    BOLD_hat = model.forward(model, E, Z, params);
                    
                case 'cross_valid'
                    stim_dim = size(E, length(size(E)));
                    stim_ind = 1:stim_dim;
                    BOLD_hat = nan(length(size(E)), 1);
                    % predict the BOLD value with given param
                    for idx = stim_ind
                        param_test = params(:, idx);
                        E_test = E(:, :, :, :, idx);
                        Z_test = Z(:, :, :, :, idx);
                        BOLD_hat(idx) = model.forward(model, E_test, Z_test, param_test);
                    end 
            end
        end
        
        % fcross valid
        function [BOLD_pred, params, R2, model] = fit(model, E, Z, BOLD_tar, verbose, cross_valid, save_info)
            
            if (nargin < 6), cross_valid = 'one'; end
            
            switch cross_valid
                
                case 'one'
                    
                    % optimize to find the best 
                    [~, param, loss_history] = model.optim(model, E, Z, BOLD_tar, verbose);
                    params = param;
                    loss_histories = loss_history;
                    model.loss_log = loss_histories;
                    % predict test data 
                    BOLD_pred = model.forward(model, E, Z, param);
                    % measure the goodness of the fit
                    R2 = model.metric(BOLD_pred, BOLD_tar);
                    % fix the parameter for the future prediction, usually
                    % not used 
                    % model  = model.fixparameters(model, param);
                    
                case 'cross_valid'
                    
                    % achieve stim vector
                    last_idx = length(size(E));
                    stim_dim = size(E, last_idx); 
                    stim_vector = save_info.start_idx:size(E, last_idx);

                    % storage, try to load the saved history, if any
                    if save_info.start_idx == 1
                        params    = nan(model.num_param, stim_dim);
                        BOLD_pred = nan(1, stim_dim);
                    else 
                        stim_vector = save_info.start_idx : size(E, last_idx);
                        load(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        load(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_pred');
                    end
                    losses    = nan(1, stim_dim);
                    loss_histories = nan(model.fittime, stim_dim);

                    % cross_valid  
                    for knock_idx = stim_vector
                        fprintf('fold %d \n', knock_idx)

                        % train vector and train data
                        keep_idx = setdiff(stim_vector, knock_idx);
                        E_train  = E(:, :, :, :, keep_idx);
                        Z_train  = Z(:, :, :, :, keep_idx);
                        tar_train = BOLD_tar(keep_idx);
                        E_test   = E(:, :, :, :, knock_idx);
                        Z_test   = Z(:, :, :, :, knock_idx);
                      
                        % fit the training data 
                        [loss, param, loss_history] = model.optim(model, E_train, Z_train, tar_train, verbose);
                        params(:, knock_idx) = param;
                        losses(knock_idx) = loss;
                        loss_histories(:, knock_idx) = loss_history;
                        
                        % predict test data 
                        BOLD_pred(knock_idx) = model.forward(model, E_test, Z_test, param);
                        
                        % save files for each cross validated fold
                        save(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        save(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d_fold-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_pred');
                    end 
                    
                    % evaluate performance of the algorithm on test data
                    R2 = model.metric(BOLD_pred, BOLD_tar);
                    
            end
        
        end            
    end
end