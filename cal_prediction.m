function [ para, BOLD_prediction, Rsquare ] = cal_prediction( dataset, roi, which_model, which_type, fittime ,v2_mean_op , E_op ,w_d, weight_E )
% This function is used to calculate the BOLD prediction of each dataset.

% The first value means dataset: e.p. Ca69_v1
% Second value means model: e.p. std
% Thrid value means type of the model: e.p.

% Load the dataset for our training the model


% load the right trainning data according to the dataset we choose
if isnumeric(dataset)
    
    load(sprintf('dataset%02d.mat', dataset), 'v_mean');
    
    v_mean = v_mean(roi , : );
    
elseif strcmp(dataset, 'new')
    v_mean = v2_mean_op;
    
else
    disp('Choose the right dataset')
end

% load  input of our model

switch which_type
    
    % Load the input of the model according to the kinds of model we choose
    case 'orientation'
        
        % Because this is a model care much about the variance of the
        % orientation, we load Etot
        if isnumeric(dataset)
            load(sprintf('E_ori_%02d.mat', dataset), 'E_ori');
        elseif strcmp(dataset, 'new')
            E_ori = E_op;
        else
            disp('input the right data')
        end
        
        % Then we begin our model fitting with random start point.
        
        % Set up the random start points.
        % Set up the boundary of paramters
        LB=  [  0,    0,  0.01];
        UB=  [200,  100,  1];
        PLB= [  0.1,  1,  0.10];
        PUB= [150,   10,  0.50];
        
        % Random the start point
        x0_w = LB(1) + (UB(1) - LB(1))*rand(fittime, 1);
        x0_g = LB(2) + (UB(2) - LB(2))*rand(fittime, 1);
        x0_n = LB(3) + (UB(3) - LB(3))*rand(fittime, 1);
        
        % Integrate them into sets
        x0_set = [x0_w, x0_g, x0_n];
        
        % Choose the which model we are going to fit and assign it into
        % the function
        fun=@(x) FUNF(x, E_ori, v_mean, which_model , 'orientation' );
        opts.Display = 'final';
        % Run n times with multiple start points
        for ii = 1: size(x0_set, 1)
            
            % Sign
            ii;
            
            % Find the optimal point with BADS
            [x(ii, :), SSE(ii)]=bads(fun,  x0_set(ii, :), LB, UB, PLB, PUB, [], opts);
            %[x(ii, :), SSE(ii)]=fmincon(fun,  x0_set(ii, :), [], [], [],[], LB, UB);
            %[x(ii, :), SSE(ii)]=fminsearch(fun,  x0_set(ii, :));
            
        end
        
        % find the lowest SSE
        trials = find(SSE == min(SSE));
        para(:) = x(trials(1), :);
        
        % Assign the parameter
        lambda = para(1);
        g = para(2);
        n = para(3);
        
        % calculate normalized energy cording the model  we choose
        switch which_model
            case 'contrast'
                % Energy model
                d = E_ori; % ori x example x stimili
            case 'normStd'
                % std model
                d = E_ori ./(1 + lambda.*std(E_ori , 1)); % ori x example x stimili
            case 'normVar'
                % var model
                d = E_ori.^2 ./(1 + lambda^2.*var(E_ori, 1)); % ori x example x stimili
            case 'normPower'
                d = E_ori.^2./( 1 + lambda^2.*mean(E_ori.^2, 1)); % ori x example x stimili
            otherwise
                disp('Please select the right model')
        end
        
        % sum over orientation
        s = squeeze(mean(d , 1)) ; %  example x stimili
        
    case 'space'
        
        E_space = E_op;
        
        
        switch which_model
            case 'SOC'
                %DISK
                
                % Set up the random start points.
                % Set up the boundary of paramters
                LB= [ 0, 0, 0];         
                UB= [1, 100, 1];
                PLB= [0.5, 0, 0];
                PUB=[1, 10, 1];

                
                %LB=  [0, 0, .2];
                %UB=  [0, 100, .2];
                %PLB= [0, 0, .2];
                %PUB= [0, 10, .2];


                % Random the start point
                x0_c = LB(1) + (UB(1) - LB(1))*rand(fittime, 1);
                x0_g = LB(2) + (UB(2) - LB(2))*rand(fittime, 1);
                x0_n = LB(3) + (UB(3) - LB(3))*rand(fittime, 1);
                
                % Integrate them into sets
                x0_set = [x0_c, x0_g, x0_n];
                
                % Choose the which model we are going to fit and assign it into
                % the function
                fun=@(x) FUNF(x, E_space, v_mean, which_model, 'space', w_d);
            case 'ori_surround'
                %DISK
                
                % Set up the random start points.
                % Set up the boundary of paramters
                LB= [ 0, 0, 0];
                UB= [80, 100, 1];
                PLB= [0.5, 0, 0];
                PUB=[20, 10, .5];
                
                % Random the start point
                x0_w = LB(1) + (UB(1) - LB(1))*rand(fittime, 1);
                x0_g = LB(2) + (UB(2) - LB(2))*rand(fittime, 1);
                x0_n = LB(3) + (UB(3) - LB(3))*rand(fittime, 1);
                
                % Integrate them into sets
                x0_set = [x0_w, x0_g, x0_n];
                
                % Choose the which model we are going to fit and assign it into
                % the function
                fun=@(x) FUNF(x, E_space, v_mean, which_model, 'space', w_d, weight_E );
        end
        % Run n times with multiple start points
        for ii = 1: size(x0_set, 1)
            
            % Sign
            ii
            
            % Find the optimal point with BADS
            [x(ii, :), SSE(ii)]=bads(fun,  x0_set(ii, :), LB, UB, PLB, PUB);
            %[x(ii, :), SSE(ii)]=fmincon(fun,  x0_set(ii, :), [], [], [],[], LB, UB);
            %[x(ii, :), SSE(ii)]=fminsearch(fun,  x0_set(ii, :));
            
        end
        
        % find the lowest SSE
        trials = find(SSE == min(SSE));
        para(:) = x(trials(1), :);
        
        switch which_model
            
            case 'SOC'
                % Assign the parameter
                c = para(1);
                g = para(2);
                n = para(3);
                % Do a variance-like calculation
                v =  (E_space - c*mean(mean(E_space, 1) , 2)).^2; % X x Y x ep x stimuli
                % Create a disk as weight
                d = bsxfun(@times, v, w_d); % X x Y x ep x stimuli
                
            case 'ori_surround'
                % Assign the parameter
                w = para(1);
                g = para(2);
                n = para(3);
                
                d_theta = E_space./(1+ w * weight_E ); %E: X x Y x theta x ep x stimuli
                v = squeeze( mean( d_theta, 3 ) ); % X x Y x ep x stimuli
                % Create a disk as weight
                d = bsxfun(@times, v, w_d); % X x Y x ep x stimuli
                
            otherwise
                disp('choose the right model')
        end
        
        % Sum over spatial position
        s = squeeze(mean(mean( d , 1) , 2)); % ep x stimuli
        
    otherwise
        disp('Please select the right mode for fitting')
end

% Nonlinearity
BOLD_prediction_ind = g.*s.^n; % ep x stimuli

% Sum over different examples
BOLD_prediction = squeeze(mean(BOLD_prediction_ind, 1)); % stimuli

% calculate the Rsquare
Rsquare= 1 - var(v_mean - BOLD_prediction)/var(v_mean);

end

