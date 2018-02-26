function [ para_set , BOLD_prediction , Rsquare ]=cross_validation(which_data, which_model, which_type, fittime, v_mean_op , E_op , w_d)

addpath(genpath(fullfile(pwd,'ROImean')));
addpath(genpath(fullfile(pwd,'E')));
% Load the data and create a vector to knock out the

switch which_data
    case {'Ca69_v1' , 'Ca69_v2' , 'Ca69_v3'}
        load E_ori_69
        E_test = E_ori_69;
        knock_out = [1:50];
        
        load v_mean_69
        switch which_data
            case 'Ca69_v1'
                v_mean = v_mean_69(1 , : );
            case 'Ca69_v2'
                v_mean = v_mean_69(2 , : );
            case 'Ca69_v3'
                v_mean = v_mean_69(3 , : );
        end
        
    case {'Ca05_v1' , 'Ca05_v2' , 'Ca05_v3'}
        
        load E_ori_05;
        E_test = E_ori_05;
        knock_out = [1:48];
        
        load v_mean_05;
        switch which_data
            case 'Ca05_v1'
                v_mean = v_mean_05(1 , : );
            case 'Ca05_v2'
                v_mean = v_mean_05(2 , : );
            case 'Ca05_v3'
                v_mean = v_mean_05(3 , : );
        end
        
        
    case {'K1_v1' , 'K1_v2' , 'K1_v3', 'K2_v1' , 'K2_v2' , 'K2_v3'}
        load E_ori_K;
        E_test=  E_ori_K;
        knock_out = [1:39];
        
        load v_mean_K1;
        load v_mean_K2;
        switch which_data
            case 'K1_v1'
                v_mean = v_mean_K1(1 , : );
            case 'K1_v2'
                v_mean = v_mean_K1(2 , : );
            case 'K1_v3'
                v_mean = v_mean_K1(3 , : );
            case 'K2_v1'
                v_mean = v_mean_K2( 1 , : );
            case 'K2_v2'
                v_mean = v_mean_K2(2 , : );
            case 'K2_v3'
                v_mean = v_mean_K2(3 , : );
         end
        
    case 'new'
        v_mean = v_mean_op;
        E_test = E_op;
        knock_out = [1 : size(v_mean , 2)];
        
    otherwise
        disp('Choose the right dataset')
end



for knock_index  = knock_out
    
    switch which_type
        
        case 'orientation'
            
            % The stimuli we leave
            knock_index
            
            % Discuss three possible situations
            if knock_index ==1
                E_vali = E_test(: , :  , 2:end);
                mean_vali = v_mean(2:end);
            elseif knock_index == knock_out(end)
                E_vali = E_test(: , :  ,1:end-1);
                mean_vali = v_mean(1:end-1);
            else
                E_vali = E_test( : , : , [1:knock_index-1, knock_index + 1:end]);
                mean_vali = v_mean([1:knock_index-1, knock_index + 1:end]);
            end
            
            % fit the other data to get the parameters
            para = cal_prediction('new', which_model, which_type, fittime ,mean_vali , E_vali);
            
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
            
            % Discuss three possible situations
            if knock_index ==1
                E_vali = E_test(: , :  , : , 2:end); % x x y x ep x stimuli
                mean_vali = v_mean(2:end);
            elseif knock_index == knock_out(end)
                E_vali = E_test(: , :  , : , 1:end-1);
                mean_vali = v_mean(1:end-1);
            else
                E_vali = E_test( : , : , : , [1:knock_index-1, knock_index + 1:end]);
                mean_vali = v_mean([1:knock_index-1, knock_index + 1:end]);
            end
            
            para = cal_prediction('new', which_model, which_type, fittime ,mean_vali , E_vali , w_d);
            
            % fix the parameter and predict the leave-out response
            c = para(1);
            g = para(2);
            n = para(3);
            
            % Assign into the right dataset
            E_space = E_test( : , :  , : , knock_index); % ori x example x 1
            
            % Do a variance-like calculation
            v =  (E_space - c*mean(mean(E_space, 1) , 2)).^2; % X x Y x ep x stimuli
            
            % Create a disk to prevent edge effect
            lambda = gen_disk(size(E_space , 1) , size(E_space , 3), 1 , 'disk');
            d = lambda.*v;  % X x Y x ep x 1
            
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

if isequal( size(v_mean) , size(BOLD_prediction)) == 0
    BOLD_prediction = BOLD_prediction';
end

% calculate the Rsquare
Rsquare= 1 - var(v_mean - BOLD_prediction)/var(v_mean);

end