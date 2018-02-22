%
load E_xy_K
load v_mean_K1
load v_mean_K2
v_mean_test = {v_mean_K1(1:30) , v_mean_K2(1:30)}
%% Choose stimuli
choose_vector = [1: 30 ];
for which_mean = 1: 2
    
    test_E_xy_K = E_xy_K( : , : , : , 1:30);
    v_mean = v_mean_test{which_mean};
    test_v_mean = v_mean
    
    [ w_d ] = gen_disk( size(test_E_xy_K , 1) ,  size(test_E_xy_K , 3)  ,  size(test_E_xy_K , 4) );
    
    for which_area = 1:3
        
        v_mean = test_v_mean(which_area , : )
        
        [ para_SOC(: , which_area, which_mean), BOLD_prediction_SOC( : , which_area, which_mean) , Rsquare_SOC(which_area, which_mean) ] = cal_prediction( 'new' , 'SOC' , 'space', 3 ,v_mean , test_E_xy_K ,w_d)
    end
end

%% Save the results
save_address = fullfile(pwd, 'results' );

save([save_address , '\para_SOC'] , 'para_SOC');
save([save_address , '\BOLD_prediction_SOC'] , 'BOLD_prediction_SOC');
save([save_address , '\Rsquare_SOC'] , 'Rsquare_SOC');

%%
addpath(genpath(fullfile(pwd,'plot')));
allsit = {'K1_testSOC_v1' , 'K1_testSOC_v2' , 'K1_testSOC_v3' ; 'K2_testSOC_v1' , 'K2_testSOC_v2' , 'K2_testSOC_v3'}

for r =1:3
    for c= 1:2
        situations = allsit{r + 2*(c-1)}
        plot_BOLD(situations , BOLD_prediction_SOC( : , r, c ) , {'data' , 'SOC'});
    end
end

