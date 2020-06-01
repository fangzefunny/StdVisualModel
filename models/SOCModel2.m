classdef SOCModel2 < SOCModel 
    
    % The basic properties of the class
    properties 
        
        receptive_weight = false
       
    end
    
    methods
        
        % init the model
        function model = SOCModel2( optimizer, fittime, param_bound, param_pbound)
            
            model = model@SOCModel();
           
            if (nargin < 4), param_pbound = [   .5, 1; 0,     2;  .1,  .5 ]; end
            if (nargin < 3), param_bound   = [ -10,  0.; -10, 10;  -6,   2  ]; end
            if (nargin < 2), fittime = 40; end
            if (nargin < 1), optimizer = 'fmincon';end
            
            param_num = 3;
            
            if size(param_bound,1) ~= param_num 
                error('Wrong Bound')
            elseif size(param_pbound, 1) ~= param_num 
                error('Wrong Possible Bound')
            end
            
            model.param_bound    = param_bound;
            model.param_pbound = param_pbound; 
            model.fittime                   = fittime;
            model.optimizer             = optimizer; 
            model.num_param        = param_num ;
            model.param_name      = [ 'c'; 'g'; 'n' ];
            model.legend                  = 'SOC_bound'; 
            model.model_type        = 'space';
            model.param                   = [];
            model.receptive_weight = false; 
        end
                       
    end
           
    methods ( Static = true )
        
        % fix parameters
        function model = fixparameters( model, param )
            model.param = param;
            model.legend = sprintf('normVar %s=%.2f %s=%.2f %s=%.2f',...
                            model.param_name(1), param(1),...
                            model.param_name(2), param(2),...
                            model.param_name(3), param(3));
                            
        end
        
       % function: choose weight 
       function model = disk_weight( model, height)
           
           model = disk_weight@SOCModel( model, height);
           
       end
        
       % function: f()
        function y_hat = forward(model, E, param )
            
            y_hat = forward@SOCModel( model, E, param);
           
        end
            
        % predict the BOLD response: y_hat = f(x)
        function BOLD_pred = predict( model, E_ori )
            
            % call subclass
            BOLD_pred = predict@SOCModel( model, E_ori);
            
        end
        
        % calculate the r sqaure
        function Rsquare = metric( BOLD_pred, BOLD_target)
            
            % call subclass
            Rsquare = metric@SOCModel( BOLD_pred, BOLD_target);
            
        end
        
         % calculate the mse
        function loss= mse( BOLD_pred, BOLD_target)
            
            % call subclass
            loss = mse@SOCModel( BOLD_pred, BOLD_target);
            
        end
        
        % loss function with sum sqaure error: sum( y - y_hat ).^2
        function sse = loss_fn( param, model, E_ori, y_target)
            
            % call subclass 
            sse = loss_fn@SOCModel( param, model, E_ori, y_target);
            
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim( model, E_ori, BOLD_target, verbose)
            
            % call subclass
            [loss, param, loss_history]  = optim@SOCModel( model, E_ori, BOLD_target, verbose);
        
        end
        
        % fit and cross valid
        function [BOLD_pred, params, Rsquare, model] = fit( model, E_xy, BOLD_target, verbose, cross_valid)
            
           if (nargin < 5), cross_valid = 'one'; end
             [BOLD_pred, params, Rsquare, model] = fit@SOCModel( model, E_xy, BOLD_target, verbose, cross_valid);
             
        end
            
    end
end