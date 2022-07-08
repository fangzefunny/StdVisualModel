classdef oOTS < contrastModel 
    
    % The basic properties of the class
    properties 
        receptive_weight = false
    end
    
    methods
        
        % init the model
        function model = oOTS(optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
           
            if (nargin < 4), param_pbound = [  .1,   4;    1,   5;  -20,  20]; end
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
            model.param_name   = ['w'; 'g'; 'n'];
            model.legend       = 'oriSurround'; 
            model.model_type   = 'space';
            model.param        = [];
            model.receptive_weight = false; 
        end
                       
    end
           
    methods (Static = true)
                
       % function: choose weight 
       function model = disk_weight(model, height)
           
           % create a meshgrid
           [X , Y] = meshgrid(linspace(-1 , 1, height));
           
           % Create a disk with certain size
            w = zeros(height,  height);
            panel = X.^2 + Y.^2;

            % Choose the radius of the disk ,  3 std of the edge size 
            theresold = .75;
            
            % pixels < theresold
            [index] = find(panel < theresold);
            w(index) = 1;
            
            % assgin weight 
           model.receptive_weight = w;
       end
        
       % function: f()
        function y_hat = forward(model, E, Z, param)
            
            if model.receptive_weight ==false
                height = size(E, 1) ;
                model = model.disk_weight(model, height);
            end
             
            % get the parameters
            w = param(1);
            g = param(2);
            n = param(3);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            d = E ./ (1 + w * Z); 
            v = squeeze(mean(d, 3));
            d = bsxfun(@times, v, model.receptive_weight);
                        
            % Sum over spatial position
            s = squeeze(mean(mean(d , 1) , 2)); % ep x stimuli
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end
        
        
        % function: f()
        function y_hat = forward2(model, E, Z, param)
            
            if model.receptive_weight ==false
                height = size(E, 1) ;
                model = model.disk_weight(model, height);
            end
             
            % get the parameters
            w = param(1);
            b = param(2);
            n = param(3);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            d = E ./ (b + w * Z); 
            v = squeeze(mean(d, 3));
            d = bsxfun(@times, v, model.receptive_weight);
                        
            % Sum over spatial position
            s = squeeze(mean(mean(d , 1) , 2)); % ep x stimuli
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end
        
        % function: f()
        function y_hat = forwardClassic(model, E, Z, param)
            
            if model.receptive_weight ==false
                height = size(E, 1) ;
                model = model.disk_weight(model, height);
            end
             
            % get the parameters
            w = param(1);
            g = param(2);
            n = param(3);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            d = E ./ (w + Z); 
            v = squeeze(mean(d, 3));
            d = bsxfun(@times, v, model.receptive_weight);
                        
            % Sum over spatial position
            s = squeeze(mean(mean(d , 1) , 2)); % ep x stimuli
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end
    end
end