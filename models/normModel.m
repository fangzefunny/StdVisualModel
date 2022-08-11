classdef normModel < oriSurroundModel 
    
    % The basic properties of the class
    properties 
    end
    
    methods
        
        % init the model
        function model = normModel(optimizer, fittime, param_bound, param_pbound)
            
            model = model@oriSurroundModel();
           
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
            model.num_param    = param_num ;
            model.fparam_name  = {'w', 'b', 'alpha'};
            model.param_name   = {'sigma', 'g', 'alpha'};
            model.legend       = 'DN'; 
            model.model_type   = 'space';
            model.param        = [];
            model.model_idx    = 4;
        end
                       
    end
           
    methods (Static = true)
                
       % function: f()
        function y_hat = forward(model, x, param)
             y_hat = forward@oriSurroundModel(model, x, param);
        end
        
        % print the parameters
        function param= print_param(model, param)
            param = print_param@oriSurroundModel(model, param);
        end
        
        % print the parameters
        function param= fprint_param(model, param)
            param = fprint_param@oriSurroundModel(model, param);
        end
        
        % measure the goodness of 
        function R2 = metric(BOLD_pred, BOLD_tar)
            R2 = metric@oriSurroundModel(BOLD_pred, BOLD_tar);
        end
        
         % measure the goodness of 
        function loss= rmse(BOLD_pred, BOLD_tar)
            loss = rmse@oriSurroundModel(BOLD_pred, BOLD_tar);
        end
        
        % loss function with sum sqaure error: sum(y - y_hat).^2
        function mse = loss_fn(param, model, x, y_tar)
            mse = loss_fn@oriSurroundModel(param, model, x, y_tar);
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim(model, x,  BOLD_tar, verbose)
            [loss, param, loss_history] = ...
                optim@oriSurroundModel(model, x,  BOLD_tar, verbose);
        end
        

        % fcross valid
        function [BOLD_hat, params, R2, model] = fit(model, x, BOLD_tar, verbose, cross_valid, save_info)
            [BOLD_hat, params, R2, model] = ...
                fit@oriSurroundModel(model, x, BOLD_tar, verbose, cross_valid, save_info);
        end            
    end
end