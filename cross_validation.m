function [ para_set , BOLD_prediction , Rsquare ]=cross_validation(dataset, roi , which_model, which_type, fittime, v_mean_op , E_op , w_d, weight_E_test)

% Load the data and create a vector to knock out the

if isnumeric(dataset)
    
    fname = sprintf('dataset%02d.mat', dataset);
    load(fname, 'v_mean');
    v_mean = v_mean(roi, : );
    
    fname = sprintf('E_ori_%02d.mat', dataset);
    load(fname, 'E_ori');
    E_test = E_ori;
    
    switch dataset
        case 1, knock_out = 1:50;
        case 2, knock_out = 1:48;
        case 3, knock_out = 1:39;
        case 4, knock_out = 1:39;
    end
elseif strcmp(dataset, 'new')
    v_mean = v_mean_op;
    E_test = E_op;
    knock_out = 1 : size(v_mean , 2);
else
    disp('Choose the right dataset')
end

BOLD_prediction = nan(size(v_mean));

for knock_index  = knock_out
     
    keep_index = setdiff(knock_out, knock_index);

    switch which_type
        
        case 'orientation'
            
            % The stimuli we leave
            knock_index
            
            % Discuss three possible situations
            E_vali = E_test(: , :  , keep_index);
            mean_vali = v_mean(keep_index);
            
            % fit the other data to get the parameters
            para = cal_prediction('new', [], which_model, which_type, fittime ,mean_vali , E_vali);
            
            % fix the parameter and predict the leave-out response
            lambda = para(1);
            g = para(2);
            n = para(3);
            
            % Assign into the right dataset
            E_ori = E_test(: , :  ,knock_index); % ori x example x 1
            
            % calculate normalized energy cording the model  we choose
            switch which_model
                case 'contrast'
                    % contrast model
                    d = E_ori; % ori x example x 1
                case 'normStd'
                    % normstd model
                    d = E_ori ./(1 + lambda.*std(E_ori , 1)); % ori x example x 1
                case 'normVar'
                    % normvar model
                    d = E_ori.^2 ./(1 + lambda^2.*var(E_ori, 1)); % ori x example x 1
                case 'normPower'
                    % normPower model
                    d = E_ori.^2./( 1 + lambda^2.*mean(E_ori.^2, 1)); % ori x example x 1
                otherwise
                    disp('Please select the right model')
            end
            
            % sum over orientation
            s = squeeze(mean(d , 1));  %  example x 1
            
        case 'space'
            
            % The stimuli we leave
            knock_index
            
            % E for training stimuli
            E_vali = E_test(: , :  , : , :, keep_index); % x x y x theta x ep x stimuli
            
            % BOLD data for training stimuli
            mean_vali = v_mean(keep_index);
            
            if strcmp( which_model, 'ori_surround' )
                weight_E_vali = weight_E_test(: , :  , : , :, keep_index);
            end
                        
            switch which_model
                case 'SOC'
                    
                    % mean over orientation
                    E_vali = squeeze(mean (E_vali, 3));
                    
                    para = cal_prediction('new', [], which_model, which_type, fittime ,mean_vali , E_vali , w_d);
                    
                    % fix the parameter and predict the leave-out response
                    c = para(1);
                    g = para(2);
                    n = para(3);
                    
                    % Assign into the right dataset
                    E_space = E_test( : , :  , : , knock_index); % ori x example x 1
                    
                    % mean over orientation
                    E_space = squeeze(mean (E_space, 3));
                    
                    % Do a variance-like calculation
                    v =  (E_space - c*mean(mean(E_space, 1) , 2)).^2; % X x Y x ep x stimuli
                    
                    % Create a disk to prevent edge effect
                    d = w_d.*v;  % X x Y x ep x 1
                    
                case 'ori_surround'
                    
                    para = cal_prediction('new', [], which_model, which_type, fittime ,mean_vali , E_vali , w_d, weight_E_vali );
                 
                    w = para(1);
                    g = para(2);
                    n = para(3);
                    
                    % Assign into the right dataset
                    E_space = E_test(: , :  ,knock_index); % ori x example x 1
                    weight_E = weight_E_test(: , :  , : , :, knock_index );
                    
                    d_theta = E_space ./(1 + w * weight_E ); %E: X x Y x theta x 1 
                    d = squeeze( mean( d_theta, 3 ) );
                   
            end
 
            
            % Sum over spatial position
            s = squeeze(mean(mean( d , 1) , 2)); % ep x 1
    end
    
    % Nonlinearity
    BOLD_prediction_ind = g.*s.^n; % ep x 1
    
    % Sum over different examples
    BOLD_prediction(knock_index) = squeeze(mean(BOLD_prediction_ind)); % scalar
    
    % Collect the parameters
    para_set( knock_index, :) = para;
    
end

if ~isequal( size(v_mean) , size(BOLD_prediction))
    BOLD_prediction = BOLD_prediction';
end

% calculate the Rsquare
Rsquare= 1 - sum((v_mean - BOLD_prediction).^2)/sum((v_mean-mean(v_mean)).^2);

end