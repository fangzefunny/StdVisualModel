classdef contrastModel
    
    % The basic properties of the class
    properties 
        optimizer               
        fittime        
        num_param    = 2
        param_name   = ['g'; 'n']
        param        = []
        param_bound  = [ 0, 100; 0,   1  ]
        param_pbound = [ 1,  10;  .1, .5 ]
        model_type   = 'orientation'
        legend       = 'CE'
        loss_log     = []
    end
    
    methods
        
        % init the model
        function model = contrastModel( optimizer, fittime, param_bound, param_pbound )
            
            if (nargin < 4), param_pbound = [ 1,  10;  .1, .5 ]; end
            if (nargin < 3), param_bound  = [ -6, 5;  -6,   1  ]; end
            if (nargin < 2), fittime = 40; end
            if (nargin < 1), optimizer = 'fmincon';end
            
            if size(param_bound,1) ~= model.num_param
                disp('Wrong Bound')
            elseif size(param_pbound, 1) ~= model.num_param
                disp('Wrong Possible Bound')
            end
            
            model.param_bound  = param_bound;
            model.param_pbound = param_pbound; 
            model.fittime      = fittime;
            model.optimizer    = optimizer; 
        end
           
    end
        
    methods ( Static = true )
        
        % fix parameters
        function model = fixparameters( model, param )
            model.param = param;
            model.legend = sprintf('contrast %s=%.2f %s=%.2f',...
                            model.param_name(1), param(1),... 
                            model.param_name(2), param(2) );
        end
        
        % the core model function 
        function y_hat = forward(model, x, param )
            
            % set param
            g = exp(param(1));
            n = exp(param(2));
            
            % d: ori x exp x stim
            d = x;
            
            % sum over orientation, s: exp x stim 
            s = mean(d, 1);

            % add gain and nonlinearity, yi_hat: exp x stim
            yi_hat = g .* s.^n;
      
            % Sum over different examples, y_hat: stim 
            y_hat = squeeze(mean(yi_hat, 2))';
   
        end

        % foward model to generate an image 
        function x_hat = reconstruct(model, E_xy, param)

            % set param
            g = exp(param(1));
            n = exp(param(2));
            
            % d: ori x exp x stim
            d = squeeze(mean(E_xy,3));
            
            % sum over orientation, s: exp x stim 
            x_hat = g .* d.^n;

        end

        function err = recon_err( model, x, E, params)

            x_hat = model.reconstruct( model, E, params);
            mean(x(:))
            nX = size(E,1);
            nS = size(E,5);
            %pad the stimuli
            pad_x = zeros(nX, nX, 9, nS);
            nP = (nX - size(x,1))/2;
            pad_x( nP+1:nX-nP, nP+1:nX-nP, :, :) = x( :, :, :, :);
            err2 = (pad_x - x_hat).^2;
            err  = mean( err2(1:3));

        end
            
        % predict the BOLD response: y_hat = f(x)
        function BOLD_pred = predict( model, E_ori )
            
            BOLD_pred = model.forward(model, E_ori, model.param );
            
        end
        
        % measure the goodness of 
        function Rsquare = metric( BOLD_pred, BOLD_target )
            
            Rsquare = 1 - sum((BOLD_target - BOLD_pred).^2) / sum((BOLD_target - mean(BOLD_target)).^2);
            
        end
        
        % measure the mse 
        function loss = rmse( BOLD_pred, BOLD_target )
            
            loss = double(sqrt(mean((BOLD_pred- BOLD_target).^2)));
            
        end
        
        
        % loss function with sum sqaure error: sum( y - y_hat ).^2
        function sse = loss_fn(param, model, E_ori, y_target )
            
            % predict y_hat: 1 x stim 
            y_hat = model.forward(model, E_ori, param );
            
            % square error
            square_error = (y_target - y_hat).^2;
            
            % sse
            sse = double(mean(square_error));
            
        end
        
        % fit the data 
        function [loss, param, loss_history] = optim( model, E_ori, BOLD_target, verbose )
            
            % set up the loss function
            func=@(x) model.loss_fn( x, model, E_ori, BOLD_target );
            
            opts.Display = verbose;
            
            % set up the bound
            lb  = model.param_bound( :, 1 );
            ub  = model.param_bound( :, 2 );
            plb = model.param_pbound( :, 1 );
            pub = model.param_pbound( :, 2 );
            
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
                
                fprintf('   fit: %d, loss: %.4f \n   params:', ii, sse(ii)) 
                disp(exp(x(ii,:)))
            end
            
            % find the lowest sse
            loss  = min(sse);
            trial = find( sse == loss );
            param = x( trial(1), : ); 
            loss_history = sse;
            
            
        end
        
        % fit the data
        function [BOLD_pred, params, Rsquare, model] = fit( model, E_ori, BOLD_target, verbose, cross_valid, save_info)
            
            if (nargin < 5), cross_valid = 'one'; end
            
            switch cross_valid
                
                case 'one'
                    
                    % optimize to find the best 
                    [loss, param, loss_history] = model.optim( model, E_ori, BOLD_target, verbose );
                    params = param;
                    loss_histories = loss_history;
                  
                    % predict test data 
                    BOLD_pred = model.forward(model, E_ori, param );
                    Rsquare = 1 - sum((BOLD_target - BOLD_pred).^2) / sum((BOLD_target - mean(BOLD_target)).^2);
                    model  = model.fixparameters( model, param );
                    
                case 'cross_valid'
                 
                    % achieve stim vector
                    % achieve stim vector
                    last_idx = length(size( E_ori ));
                    stim_dim = size( E_ori, last_idx ); 
                    stim_vector = save_info.start_idx : size( E_ori, last_idx );
    
                    % storage, try to load the saved history, if any
                    if save_info.start_idx == 1
                        params    = nan( model.num_param, size( E_ori, stim_dim ) );
                        BOLD_pred = nan( 1, size( E_ori, stim_dim ) );
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
                        keep_idx = setdiff( stim_vector, knock_idx );
                        E_train  = E_ori( :, :, keep_idx );
                        target_train = BOLD_target( keep_idx );
                        E_test   = E_ori( :, :, knock_idx );
                      
                        % fit the training data 
                        [loss, param, loss_history] = model.optim( model, E_train, target_train, verbose );
                        params( :, knock_idx ) = param;
                        
                        % predict test data 
                        BOLD_pred( knock_idx ) = model.forward(model, E_test, param);

                        % save files for each cross validated fold
                        save(fullfile(save_info.dir, sprintf('parameters_data-%d_roi-%d_model-%d.mat',...
                                        save_info.dataset, save_info.roi, save_info.model_idx)) , 'params');
                        save(fullfile(save_info.dir, sprintf('predictions_data-%d_roi-%d_model-%d.mat',...
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