classdef normCEModel < contrastModel 
    
    % The basic properties of the class
    properties 
    end
    
    methods
        
        % init the model
        function model = normCEModel( optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
      
            if (nargin < 4), param_pbound = [  .1,  10;    1,  10; - 20,  20]; end
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
            model.param_name   = [ 'w'; 'g'; 'n' ];
            model.legend       = 'normCE'; 
            model.param        = [];
        end
           
    end
          
    methods (Static = true)
              
        % function: f()
        function y_hat = forward(model, x, param)
             
            % get the parameters
            w = param(1);
            g = param(2);
            n = Sigmoid(param(3));
            
            % d: ori x exp x stim
            d = x ./ (1 + w.*x); 
            
            % sum over orientation, s: exp x stim 
            s = mean(d, 1);
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 2))';
           
        end
            
        % predict the BOLD response: y_hat = f(x)
        function BOLD_pred = predict( model, E_ori , params, if_cross)
            if (nargin < 4), if_cross='cross_valid'; end
            % call subclass
            BOLD_pred = predict@contrastModel( model, E_ori, params, if_cross);
            
        end
        
        % print the parameters
        function param= print_param(model, param)
            % reshape param
            param = reshape(param, model.num_param, []);
            % set param
            param(3, :) = Sigmoid(param(3, :));
        end
        
        % measure the goodness of 
        function Rsquare = metric(pred, tar)
            Rsquare = metric@contrastModel(pred, tar);
        end
        
        % measure the goodness of 
        function loss= rmse(pred, tar)
            loss = rmse@contrastModel(pred, tar);
        end
        
        % loss function with sum sqaure error: sum( y - y_hat ).^2
        function sse = loss_fn(param, model, E, y_tar)
            sse = loss_fn@contrastModel(param, model, E, y_tar);
        end
        
        % fit the data 
        function [loss, param, loss_history] = optim(model, E, BOLD_tar, verbose)
            [loss, param, loss_history] = ...
                optim@contrastModel(model, E, BOLD_tar, verbose);
        end
        
        % fcross valid
        function [BOLD_pred, params, Rsquare, model] = fit(model, E, BOLD_tar, verbose, cross_valid, save_info)     
            if (nargin < 5), cross_valid = 'one'; end
            [BOLD_pred, params, Rsquare, model] = ...
                fit@contrastModel(model, E, BOLD_tar, verbose, cross_valid, save_info);
            
        end
            
    end
end
