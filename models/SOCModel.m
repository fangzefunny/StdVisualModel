classdef SOCModel < contrastModel 
    
    % The basic properties of the class
    properties 
        
        receptive_weight = false
       
    end
    
    methods
        
        % init the model
        function model = SOCModel( optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
           
            if (nargin < 4), param_pbound = [ .5, 1; 0,     2;  .1,  .5 ]; end
            if (nargin < 3), param_bound   = [ 0.1,   1; 0,  100;  0,   5  ]; end
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
            model.legend                  = 'SOC'; 
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
           
           % create a meshgrid
           [ X , Y ] = meshgrid( linspace( -1 , 1, height));
           
           % Create a disk with certain size
            w = zeros( height,  height);
            panel = X.^2 + Y.^2;

            % Choose the radius of the disk ,  3 std of the edge size 
            theresold = .75;
            
            % pixels < theresold
            [index ] = find( panel < theresold);
            w( index) = 1;
            
            % assgin weight 
           model.receptive_weight = w;
       end
        
       % function: f()
        function y_hat = forward(model, E, param )
            
            if model.receptive_weight ==false
                height = size(E, 1) ;
                model = model.disk_weight(model, height);
            end
             
            c = param(1);
            g = param(2);
            n = param(3);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            E = squeeze( mean( E, 3));
            
            % d: x x y x exp x stim
            v = (E - c * mean( mean(E, 1), 2)).^2; 
            d = bsxfun(@times, v, model.receptive_weight);
            
            % Sum over spatial position
            s = squeeze(mean(mean( d , 1) , 2)); % ep x stimuli
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
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
        function loss= mse( BOLD_pred, BOLD_target )
            
            % call subclass
            loss = mse@contrastModel( BOLD_pred, BOLD_target );
            
        end
        
        % loss function with sum sqaure error: sum( y - y_hat ).^2
        function sse = loss_fn( param, model, E_ori, y_target )
            
            % call subclass 
            sse = loss_fn@contrastModel( param, model, E_ori, y_target );
            
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim( model, E_ori, BOLD_target, verbose )
            
            % call subclass
            [loss, param, loss_history]  = optim@contrastModel( model, E_ori, BOLD_target, verbose );
        
        end
        
        % fcross valid
        function [BOLD_pred, params, Rsquare, model] = fit( model, E_ori, BOLD_target, verbose, cross_valid )
            
            if (nargin < 5), cross_valid = 'one'; end
           
            % call subclass
            [BOLD_pred, params, Rsquare, model] = fit@contrastModel( model, E_ori, BOLD_target, verbose, cross_valid );
            
        end
            
    end
end