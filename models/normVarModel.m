classdef normVarModel < contrastModel 
    
    % The basic properties of the class
    properties 
       
    end
    
    methods
        
        % init the model
        function model = normVarModel( optimizer, fittime, param_bound, param_pbound )
            
            model = model@contrastModel();
           
            if (nargin < 4), param_pbound = [ .1, 8; 1,  10;  .1, .5 ]; end
            if (nargin < 3), param_bound  = [ -6, 6; -6, 6; -6,  2  ]; end
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
            model.optimizer = optimizer; 
            model.num_param    = param_num ;
            model.param_name   = [ 'w'; 'g'; 'n' ];
            model.legend       = 'normVar'; 
            model.param        = [];
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
        
        % function: f()
        function y_hat = forward( model, x, param )
             
            w = exp(param(1));
            g = exp(param(2));
            n = exp(param(3));
            
            % d: ori x exp x stim
            d = x.^2 ./ (1 + w^2 .* var(x, 1) ); 
            
            % sum over orientation, s: exp x stim 
            s = mean(d, 1);
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 2))';
           
        end
            
        % predict the BOLD response: y_hat = f(x)
        function BOLD_pred = predict( model, E_ori )
            
            % call subclass
            BOLD_pred = predict@contrastModel( model, E_ori);
            
        end
        
        % measure the goodness of 
        function Rsquare = metric( BOLD_pred, BOLD_target )
            
            % call subclass
            Rsquare = metric@contrastModel( BOLD_pred, BOLD_target );
            
        end
        
        % measure the goodness of 
        function loss= rmse( BOLD_pred, BOLD_target )
            
            % call subclass
            loss = rmse@contrastModel( BOLD_pred, BOLD_target );
            
        end
        
        % loss function with sum sqaure error: sum( y - y_hat ).^2
        function sse = loss_fn( param, model, E_ori, y_target )
            
            % call subclass 
            sse = loss_fn@contrastModel( param, model, E_ori, y_target );
            
        end
        
        % fit the data 
        function [loss, param, loss_history] = optim( model, E_ori, BOLD_target, verbose )
            
            % call subclass
            [loss, param, loss_history] = optim@contrastModel( model, E_ori, BOLD_target, verbose );
        
        end
        
        % fcross valid
        function [BOLD_pred, params, Rsquare, model] = fit( model, E_ori, BOLD_target, verbose, cross_valid )
            
            if (nargin < 5), cross_valid = 'one'; end
           
            % call subclass
            [BOLD_pred, params, Rsquare, model] = fit@contrastModel( model, E_ori, BOLD_target, verbose, cross_valid );
            
        end
            
    end
end
