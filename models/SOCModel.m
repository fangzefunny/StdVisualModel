classdef SOCModel < contrastModel 
    
    % The basic properties of the class
    properties 
        receptive_weight = false
    end
    
    methods
        
        % init the model
        function model = SOCModel( optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
            
            % the parameters here are log params
            if (nargin < 4), param_pbound  = log([    .5, 1;  eps,  2; .1,.5 ]); end
            if (nargin < 3), param_bound   = log([     eps, 1;  eps, 50;  eps, 1 ]); end
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
            model.param_name   = [ 'c'; 'g'; 'n' ];
            model.legend       = 'SOC'; 
            model.model_type   = 'space';
            model.param        = [];
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
             
            c = exp(param(1));
            g = exp(param(2));
            n = exp(param(3));
            
            fprintf('c:%5.4f\tg:%5.4f\tn:%5.4f\n',c,g,n);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            E = squeeze( mean( E, 3));
            
            % d: x x y x exp x stim
            E_mean = mean( mean(E, 1), 2);
            v = (E - c * E_mean).^2; 
            d = bsxfun(@times, v, model.receptive_weight);
            
            % Sum over spatial position
            s = squeeze(mean(mean( d , 1) , 2)); % ep x stimuli
        
            % add nonlinearity, yi_hat: exp x stim
            si_n = s .^n; 
            
            % add gain: exp x stim
            yi_hat = g .* si_n;

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end
        
        % foward model to generate an image 
        function x_hat = reconstruct(model, E, param )

            if model.receptive_weight ==false
                height = size(E, 1) ;
                model = model.disk_weight(model, height);
            end
             
            c = exp(param(1));
            g = exp(param(2));
            n = exp(param(3));
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            E = squeeze( mean( E, 3));
            
            % d: x x y x exp x stim
            E_mean = mean( mean(E, 1), 2);
            v = (E - c * E_mean).^2; 
            d = bsxfun(@times, v, model.receptive_weight);
                
            % sum over orientation, s: exp x stim 
            x_hat = g .* d.^n;

        end

        function err = recon_error( model, x, param)


            x_hat = model.reconstruct( x, param);
            err2 = (x - x_hat).^2;
            err  = mean( err2(:));

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
        function [loss, param, loss_history]  = optim( model, E_ori, BOLD_target, verbose )
            
            % call subclass
            [loss, param, loss_history]  = optim@contrastModel( model, E_ori, BOLD_target, verbose );
        
        end
        
        % fit and cross valid
        function [BOLD_pred, params, Rsquare, model] = fit( model, E_xy, BOLD_target, verbose, cross_valid, save_info)
            
           if (nargin < 5), cross_valid = 'one'; end
            
            switch cross_valid
                
                case 'one'
                    
                    % optimize to find the best local minima
                    [loss, param, loss_history] = model.optim( model, E_xy, BOLD_target, verbose);
                    params = param;
                    loss_histories = loss_history;
                    % predict test data 
                    BOLD_pred = model.forward( model, E_xy, param);
                    % measure the goodness of the fit
                    Rsquare = model.metric( BOLD_pred, BOLD_target);
                     % fix the parameter for the future prediction, usually
                     % not used 
                    model  = model.fixparameters( model, param );
                    
                case 'cross_valid'
                 
                    % achieve stim vector
                    last_idx = length( size( E_xy));
                    stim_dim = size( E_xy, last_idx); 
                    stim_vector = 1 : size( E_xy, last_idx);
    
                    % storages
                    % storage, try to load the saved history, if any
                    if save_info.start_idx == 1
                        params    = nan( model.num_param, stim_dim);
                        BOLD_pred = nan( 1, stim_dim);
                    else
                        load(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d_fold-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx, save_info.start_idx-1)) , 'params');
                        load(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d_fold-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx, save_info.start_idx-1)) , 'BOLD_pred');
                    end
                    losses    = nan( 1, stim_dim);
                    loss_histories = nan( model.fittime, stim_dim);

                    % cross_valid  
                    for knock_idx = stim_vector
                        fprintf('fold %d \n', knock_idx)

                        % train vector and train data
                        keep_idx = setdiff( stim_vector, knock_idx);
                        E_train  = E_xy( :, :, :, :, keep_idx);
                        target_train = BOLD_target( keep_idx);
                        E_test   = E_xy( :, :, :, :, knock_idx);
                      
                        % fit the training data 
                        [ loss, param, loss_history] = model.optim( model, E_train, target_train, verbose );
                        params( :, knock_idx) = param;
                        
                        % use the fitted parameter to predict test data 
                        BOLD_pred( knock_idx ) = model.forward(model, E_test, param );
                        
                        % save files for each cross validated fold
                        save(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d_fold-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx, knock_idx)) , 'params');
                        save(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d_fold-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx, knock_idx)) , 'BOLD_pred');
                    end 
                    
                    % evaluate performance of the algorithm on test data
                    Rsquare = model.metric( BOLD_pred, BOLD_target);
                    
                    % bootstrap to get the param
                    params_boot = mean( params, 1 );
                    model  = model.fixparameters( model, params_boot );
                    
            end
            
            model.loss_log = loss_histories;
                      
        end
            
    end
end