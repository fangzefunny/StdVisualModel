function [ para, BOLD_prediction, Rsquare ] = cal_prediction( which_data, which_model, which_type, fittime ,v2_mean_op , E_op ,w_d)
% This function is used to calculate the BOLD prediction of each dataset.

% The first value means dataset: e.p. Ca69_v1
% Second value means model: e.p. std
% Thrid value means type of the model: e.p.

% Load the dataset for our training the model


% load the right trainning data according to the dataset we choose
if isnumeric(which_data)
    
    load(sprintf('dataset%02d.mat', which_data(1)), 'v_mean');
    
    v_mean = v_mean(which_data(2) , : );
    
elseif strcmp(which_data, 'new')
    v_mean = v2_mean_op;
    
else
    disp('Choose the right dataset')
end

% load  input of our model

% Go forwads to the right fold
addpath(genpath(fullfile(pwd,'E')));

switch which_type
    
    % Load the input of the model according to the kinds of model we choose
    case 'orientation'
        
        % Because this is a model care much about the variance of the
        % orientation, we load Etot
        if isnumeric(which_data)
            load(sprintf('E_ori_%02d.mat', which_data(1)), 'E_ori');
        elseif strcmp(which_data, 'new')
            E_ori = E_op;
        else
            disp('input the right data')
        end
        
        % Then we begin our model fitting with random start point.
        
        % Set up the random start points.
        % Set up the boundary of paramters
        LB= [ 0, 0, 0];
        UB= [200, 700, 10];
        PLB= [0.00005, 0, 0];
        PUB=[150, 10, 2];
        
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
        if isnumeric(which_data)
            load(sprintf('E_xy_%02d.mat', which_data(1)), 'E_xy');
            E_space = E_xy;
        elseif strcmp(which_data, 'new')
            E_space = E_op;
        else
            disp('input the right data')
        end
        
        %DISK
        
        % Set up the random start points.
        % Set up the boundary of paramters
        LB= [ 0, 0, 0];
        UB= [1, 100, 10];
        PLB= [0.5, 0, 0];
        PUB=[1, 10, 2];
        
        % Random the start point
        x0_c = LB(1) + (UB(1) - LB(1))*rand(fittime, 1);
        x0_g = LB(2) + (UB(2) - LB(2))*rand(fittime, 1);
        x0_n = LB(3) + (UB(3) - LB(3))*rand(fittime, 1);
        
        % Integrate them into sets
        x0_set = [x0_c, x0_g, x0_n];
        
        % Choose the which model we are going to fit and assign it into
        % the function
        fun=@(x) FUNF(x, E_space, v_mean, which_model, 'space', w_d);
        
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
        
        % Assign the parameter
        c = para(1);
        g = para(2);
        n = para(3);
        
        switch which_model
            case 'SOC'
                % Do a variance-like calculation
                v =  (E_space - c*mean(mean(E_space, 1) , 2)).^2; % X x Y x ep x stimuli
                
                % Create a disk as weight
                
                d = w_d.*v; % X x Y x ep x stimuli
                
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

% Ensure that the size of BOLD_prediction and v2_mean are the
% same
if isequal( size(v_mean) , size(BOLD_prediction)) == 0
    BOLD_prediction = BOLD_prediction';
end

% calculate the Rsquare
Rsquare= 1 - var(v_mean - BOLD_prediction)/var(v_mean);

end

