classdef oriSurroundModel < SOCModel 
    
    % The basic properties of the class
    properties 
    end
    
    methods
        
        % init the model
        function model = oriSurroundModel(optimizer, fittime, param_bound, param_pbound)
            
            model = model@SOCModel();
            
            % check the range after fitting non-cross fit 
            if (nargin < 4), param_pbound = [1e-6,  .1; 1e-2,  10;   -5,   5]; end
            if (nargin < 3), param_bound  = [-inf, inf; -inf, inf; -inf, inf]; end
            if (nargin < 2), fittime = 40; end
            if (nargin < 1), optimizer = 'classic';end
            
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
        function y_hat = forward(model, x, param)
            
            % upack the input 
            e = x{1}; z = x{2};
            
            switch model.optimizer
                
                case 'classic'
                    % get the parameters
                    sig = param(1);
                    g   = param(2);
                    alpha = Sigmoid(param(3));
                    
                    % x x y x ori x exp x stim --> x x y x exp x stim
                    d = e ./ (sig + z); 
                    d = squeeze(mean(d, 3));
                        
                    % mean over spatial position
                    s = squeeze(mean(mean(d , 1), 2)); % ep x stimuli

                    % add gain and exponential, yi_hat: exp x stim
                    yi_hat = g .* s .^ alpha;
                    
                case 'reparam'
                    % get the parameters
                    w = param(1);
                    b = param(2);
                    alpha = Sigmoid(param(3));
                    
                    % x x y x ori x exp x stim --> x x y x exp x stim
                    d = e ./ (b + w.*z); 
                    d = squeeze(mean(d, 3));
                        
                    % mean over spatial position
                    s = squeeze(mean(mean(d , 1), 2)); % ep x stimuli

                    % add gain and exponential, yi_hat: exp x stim
                    yi_hat = s .^ alpha;
            end

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
            R2 = metric@SOCModel(BOLD_pred, BOLD_tar);
        end
        
         % measure the goodness of 
        function loss= rmse(BOLD_pred, BOLD_tar)
            loss = rmse@SOCModel(BOLD_pred, BOLD_tar);
        end
        
        % loss function with sum sqaure error: sum(y - y_hat).^2
        function mse = loss_fn(param, model, x, y_tar)
            mse = loss_fn@SOCModel(param, model, x, y_tar);
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim(model, x,  BOLD_tar, verbose)
            [loss, param, loss_history] = ...
                optim@SOCModel(model, x, BOLD_tar, verbose);
        end
        
        % fit the data 
        function [BOLD_hat, params, R2, model] = fit(model, x, BOLD_tar, verbose, cross_valid, save_info)
            [BOLD_hat, params, R2, model] = ...
                fit@SOCModel(model, x, BOLD_tar, verbose, cross_valid, save_info);
        end
        
                   
    end
end