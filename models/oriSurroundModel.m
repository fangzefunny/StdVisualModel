classdef oriSurroundModel < contrastModel 
    
    % The basic properties of the class
    properties 
        receptive_weight = false
    end
    
    methods
        
        % init the model
        function model = oriSurroundModel( optimizer, fittime, param_bound, param_pbound)
            
            model = model@contrastModel();
           
            if (nargin < 4), param_pbound = [   .1,   4;    1,   5;  -20,  20]; end
            if (nargin < 3), param_bound  = [ -inf, inf; -inf, inf; -inf, inf]; end
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
            model.legend       = 'oriSurround'; 
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
        function y_hat = forward(model, E, Z, param)
            
            if model.receptive_weight ==false
                height = size(E, 1) ;
                model = model.disk_weight(model, height);
            end
             
            % get the parameters
            [w, g, n] = model.get_param( model, param);
            
            % calculate weight of E 
            %weight_E = model.cal_weight_E( model, E);
            
            % x x y x ori x exp x stim --> x x y x exp x stim
            d = E ./ ( 1 + w * Z); 
            v = squeeze( mean( d, 3));
            d = bsxfun( @times, v, model.receptive_weight);
                        
            % Sum over spatial position
            s = squeeze(mean(mean( d , 1) , 2)); % ep x stimuli
            
            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s .^ n; 

            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 1));
           
        end

        % print the parameters
        function [ w, g, n] = get_param(model, param)
            % set param
            w = param(1);
            g = param(2);
            n = Sigmoid(param(3));
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
        function sse = loss_fn(param, model, E_xy, weight_E, y_target )
            
            % predict y_hat: 1 x stim 
            y_hat = model.forward(model, E_xy, weight_E, param );
            
            % square error
            square_error = (y_target - y_hat).^2;
            
            % sse
            sse = double(mean(square_error));
        end
        
        % fit the data 
        function [loss, param, loss_history]  = optim( model, E_xy, Z,  BOLD_target, verbose )
            
           % set up the loss function
            func=@(x) model.loss_fn( x, model, E_xy, Z, BOLD_target );
            
            opts.Display = verbose;
            
            % set up the bound
            lb  = model.param_bound( :, 1);
            ub  = model.param_bound( :, 2);
            plb = model.param_pbound( :, 1);
            pub = model.param_pbound( :, 2);
            
            % init param
            x0_set = ( plb + ( pub - plb ) .* rand( model.num_param, model.fittime ) )';
            
            % storage
            x   = NaN( model.fittime, model.num_param );
            sse = NaN( model.fittime, 1 );
            
            % fit with n init
            for ii = 1:model.fittime
                
                % optimization
                switch model.optimizer
                    case 'bads'
                        [ x(ii, :), sse(ii) ] = bads( func, x0_set(ii, :), lb', ub', plb', pub', [], opts);
                    case 'fmincon'
                        [ x(ii, :), sse(ii) ] = fmincon( func, x0_set(ii, :), [], [], [], [], lb', ub', [], opts);
                end
                
                fprintf('   fit: %d, loss: %.4f \n', ii, sse(ii)) 
            end
            
            % find the lowest sse
            loss  = min(sse);
            trial = find( sse == loss );
            param = x( trial(1), : ); 
            loss_history = sse;
            
        end
        
        % Predict the BOLD response: y_hat = f(x)
        function BOLD_hat = predict( model, E, Z, params, if_cross)
            
            if (nargin < 5), if_cross='cross_valid'; end
            
            switch if_cross
            
                case 'one'
                    BOLD_hat = model.forward(model, E, Z, params);
                    
                case 'cross_valid'
                    stim_dim = size( E, length(size(E)));
                    stim_ind = 1:stim_dim;
                    BOLD_hat = nan( length(size(E)), 1);
                    % predict the BOLD value with given param
                    for idx = stim_ind
                        param_test = params( :, idx);
                        E_test = E( :, :, :, :, idx);
                        Z_test = Z( :, :, :, :, idx);
                        BOLD_hat(idx) = model.forward( model, E_test, Z_test, param_test);
                    end 
            end
        end
        
        % fcross valid
        function [BOLD_pred, params, Rsquare, model] = fit( model, E_xy, Z, BOLD_target, verbose, cross_valid, save_info )
            
            if (nargin < 6), cross_valid = 'one'; end
            
            switch cross_valid
                
                case 'one'
                    
                    % optimize to find the best 
                    [loss, param, loss_history] = model.optim( model, E_xy, Z, BOLD_target, verbose);
                    params = param;
                    loss_histories = loss_history;
                    % predict test data 
                    BOLD_pred = model.forward(model, E_xy, Z, param );
                    % measure the goodness of the fit
                    Rsquare = model.metric( BOLD_pred, BOLD_target);
                     % fix the parameter for the future prediction, usually
                     % not used 
                    model  = model.fixparameters( model, param );
                    
                case 'cross_valid'
                    
                    % achieve stim vector
                    last_idx = length( size( E_xy));
                    stim_dim = size( E_xy, last_idx); 
                    stim_vector = save_info.start_idx:size(E_xy, last_idx);

                    % storage, try to load the saved history, if any
                    if save_info.start_idx == 1
                        params    = nan( model.num_param, stim_dim);
                        BOLD_pred = nan( 1, stim_dim);
                    else
                        stim_vector = save_info.start_idx : size( E_xy, last_idx);
                        load(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        load(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_pred');
                    end
                    losses    = nan( 1, stim_dim);
                    loss_histories = nan( model.fittime, stim_dim);

                    % cross_valid  
                    for knock_idx = stim_vector
                        fprintf('fold %d \n', knock_idx)

                        % train vector and train data
                        keep_idx = setdiff( stim_vector, knock_idx );
                        E_train  = E_xy( :, :, :, :, keep_idx );
                        Z_train  = Z( :, :, :, :, keep_idx);
                        target_train = BOLD_target( keep_idx );
                        E_test   = E_xy( :, :, :, :, knock_idx );
                        Z_test   = Z( :, :, :, :, knock_idx);
                      
                        % fit the training data 
                        [loss, param, loss_history] = model.optim( model, E_train, Z_train, target_train, verbose );
                        params( :, knock_idx ) = param;
                        losses( knock_idx ) = loss;
                        loss_histories( :, knock_idx ) = loss_history;
                        
                        % predict test data 
                        BOLD_pred( knock_idx ) = model.forward( model, E_test, Z_test, param);
                        
                        % save files for each cross validated fold
                        save(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        save(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d_fold-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'BOLD_pred');
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