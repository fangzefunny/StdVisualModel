classdef SOCModel < contrastModel 
    
    % The basic properties of the class
    properties 
    end
    
    methods
        
        % init the model
        function model = SOCModel(optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
            
            % the parameters here are log params
            if (nargin < 4), param_pbound  = [ .5,   1; 1e-2,   2;  -20,  20]; end
            if (nargin < 3), param_bound   = [-inf, inf; -inf, inf; -inf, inf]; end
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
            model.num_param    = param_num ;
            model.param_name   = ['c'; 'g'; 'alpha'];
            model.legend       = 'SOC'; 
            model.model_type   = 'space';
            model.param        = [];
            model.receptive_weight = false; 
            model.model_idx    = 2;
        end
                       
    end
           
    methods (Static = true)
        
       % function: f()
        function y_hat = forward(model, E, param)
             
            % get the parameters
            c     = Sigmoid(param(1));
            g     = param(2);
            alpha = Sigmoid(param(3));
            
            %fprintf('c:%5.4f\tg:%5.4f\tn:%5.4f\n',c,g,n);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            E = squeeze(mean(E, 3));
            
            % d: x x y x exp x stim
            E_mean = mean(mean(E, 1), 2);
            d = (E - c * E_mean).^2; 
         
            % mean over spatial position
            s = squeeze(mean(mean(d , 1) , 2)); % ep x stimuli
        
            % add gain and exp, yi_hat: exp x stim
            yi_hat = g .* s.^ alpha; 
            
            % mean over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end
        
        % print the parameters
        function param= print_param(model, param)
            % reshape 
            param = reshape(param, model.num_param, []);
            % set param
            param(1, :) = Sigmoid(param(1, :));
            param(3, :) = Sigmoid(param(3, :));
        end
                    
        % predict the BOLD response: y_hat = f(x)
        function BOLD_pred = predict(model, E_ori)
            BOLD_pred = predict@contrastModel(model, E_ori);
        end
        
        % measure the goodness of 
        function Rsquare = metric(pred, tar)
            Rsquare = metric@contrastModel(pred, tar);
        end
        
         % measure the goodness of 
        function loss= rmse(pred, tar)
            loss = rmse@contrastModel(pred, tar);
        end
        
        % loss function with mean square error: mean(y - y_hat).^2
        function mse = loss_fn(param, model, E, y_tar)
            mse = loss_fn@contrastModel(param, model, E, y_tar);
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim(model, E, BOLD_tar, verbose)
            [loss, param, loss_history]  = optim@contrastModel(model, E, BOLD_tar, verbose);
        end
        
        % fit and cross valid
        function [BOLD_pred, params, R2, model] = fit(model, E, BOLD_tar, verbose, cross_valid, save_info)
            
           if (nargin < 5), cross_valid = 'one'; end
            
            switch cross_valid
                
                case 'one'
                    % optimize to find the best local minima
                    [~, param, loss_history] = model.optim(model, E, BOLD_tar, verbose);
                    params = param;
                    loss_histories = loss_history;
                    model.loss_log = loss_histories;
                    % predict test data 
                    BOLD_pred = model.forward(model, E, param);
                    % measure the goodness of the fit
                    R2 = model.metric(BOLD_pred, BOLD_tar);
                    
                case 'cross_valid'
                 
                    % achieve stim vector
                    last_idx = length(size(E));
                    stim_dim = size(E, last_idx); 
                    stim_vector = 1 : size(E, last_idx);
    
                    % storages
                    % storage, try to load the saved history, if any
                    if save_info.start_idx == 1
                        params    = nan(model.num_param, stim_dim);
                        BOLD_pred = nan(1, stim_dim);
                    else
                        load(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        load(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_pred');
                    end

                    % cross_valid  
                    for knock_idx = stim_vector
                        fprintf('fold %d \n', knock_idx)

                        % train vector and train data
                        keep_idx = setdiff(stim_vector, knock_idx);
                        E_train  = E(:, :, :, :, keep_idx);
                        tar_train = BOLD_tar(keep_idx);
                        E_test   = E(:, :, :, :, knock_idx);
                      
                        % fit the training data 
                        [~, param] = model.optim(model, E_train, tar_train, verbose);
                        params(:, knock_idx) = param;
                        
                        % use the fitted parameter to predict test data 
                        BOLD_pred(knock_idx) = model.forward(model, E_test, param);
                        
                        % save files for each cross validated fold
                        save(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        save(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_pred');
                    end 
                    
                    % evaluate performance of the algorithm on test data
                    R2 = model.metric(BOLD_pred, BOLD_tar);     
            end         
        end
            
    end
end