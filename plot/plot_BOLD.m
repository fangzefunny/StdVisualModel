function figureM1=plot_BOLD(which_data, all_prediction, legend_name , t_mean_op)

% Create a figure to carry the plot
figureM1=figure('units', 'normalized', 'outerposition', [0.1 0.05 .6 .85], 'color',[1 1 1]);

% Colors for each model
col_vector = {'k' , 'r' , 'g' , 'b' , 'y','m'};

addpath(genpath(fullfile(pwd,'data\ROImean')));

% Load the data to see how the data looks like

switch which_data
    
    case {'Ca69_v1' , 'Ca69_v2' , 'Ca69_v3'}
        load v_mean_69
        switch which_data
            case 'Ca69_v1'
                v_mean = v_mean_69( 1 , : );
            case 'Ca69_v2'
                v_mean = v_mean_69( 2 , : );
            case 'Ca69_v3'
                v_mean = v_mean_69( 3 , : );
        end
        
        
        % Use bar plot to visualize data
        
        b1 = bar(1:50 , v_mean);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        
        % Visualize the data prediction result
        for which_prediction = 1:size( all_prediction ,2)
            
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:50,model_prediction,'filled','MarkerFaceColor', col)
            
        end
        legend('data', legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            
            plot(1:5, model_prediction(1:5), col);
            hold on
            plot(6:10,model_prediction(6:10),col);
            hold on
            plot(11:15, model_prediction(11:15), col);
            hold on
            plot(16:21, model_prediction(16:21), col);
            hold on
            plot(22:24, model_prediction(22:24), col);
            hold on
            plot(25:27, model_prediction(25:27), col);
            hold on
            plot(28:30, model_prediction(28:30), col);
            hold on
            plot(31:34, model_prediction(31:34), col);
            hold on
            plot(35:38, model_prediction(35:38), col);
            hold on
            plot(39:42, model_prediction(39:42), col);
            hold on
            plot(43:46, model_prediction(43:46), col);
            hold on
            plot(47:50, model_prediction(47:50), col);
            hold on
            
        end
        
        
        % Label the group
        set(gca,'xtick',[1, 6,11,16,22,25,28,31,35,39,43,47]);
        set(gca,'XTickLabel',{'Patterns-Sparsity','Grating-Sparsity','NoiseBars-Sparsity','Waves-Sparisity','Grating-Orientation','Noisebar-Orientation','Waves-Orientation','Grating-cross','Grating-Contrast','Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        
        % The legend of the line
        g=max(v_mean)*1;
        
        %
        line([5.4,5.4],[0,g])
        hold on
        line([10.4,10.4],[0,g])
        hold on
        line([15.4,15.4],[0,g])
        hold on
        line([21.4,21.4],[0,g])
        hold on
        line([24.4,24.4],[0,g])
        hold on
        line([27.4,27.4],[0,g])
        hold on
        line([30.4,30.4],[0,g])
        hold on
        line([30.4,30.4],[0,g])
        hold on
        line([34.4,34.4],[0,g])
        hold on
        line([38.4,38.4],[0,g])
        hold on
        line([42.4,42.4],[0,g])
        hold on
        line([46.4,46.4],[0,g])
        hold on
        line([50.4,50.4],[0,g])
        
        % Add a title
        ylabel('Predicted BOLD response')
        
        
    case { 'Ca05_v1' , 'Ca05_v2' , 'Ca05_v3'}
        
        load v_mean_05
        switch which_data
            case 'Ca05_v1'
                v_mean = v_mean_05( 1 , : );
            case 'Ca05_v2'
                v_mean = v_mean_05( 2 , : );
            case 'Ca05_v3'
                v_mean = v_mean_05( 3 , : );
        end
        % Use bar plot to produce data
        
        b1 = bar(1:48 , v_mean);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:48,model_prediction(1:48),'filled','MarkerFaceColor', col)
        end
        legend('data', legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(1:5, model_prediction(1:5), col);
            hold on
            plot(6:10, model_prediction(6:10), col);
            hold on
            plot(11:15, model_prediction(11:15), col);
            hold on
            plot(16:19, model_prediction(16:19), col);
            hold on
            plot(20:22, model_prediction(20:22), col);
            hold on
            plot(23:25, model_prediction(23:25), col);
            hold on
            plot(26:28, model_prediction(26:28), col);
            hold on
            plot(29:32, model_prediction(29:32), col);
            hold on
            plot(33:36, model_prediction(33:36), col);
            hold on
            plot(37:40, model_prediction(37:40), col);
            hold on
            plot(41:44, model_prediction(41:44), col);
            hold on
            plot(45:48, model_prediction(45:48), col);
        end
        
        set(gca,'xtick',[1, 6,11,16,22,25,28,31,35,39,43,47]);
        set(gca,'XTickLabel',{'Patterns-Sparsity','Grating-Sparsity','NoiseBars-Sparsity','Waves-Sparisity','Grating-Orientation','Noisebar-Orientation','Waves-Orientation','Grating-cross','Grating-Contrast','Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        g=max(v_mean)*1.5;
        
        line([5.4,5.4],[0,g])
        hold on
        line([10.4,10.4],[0,g])
        hold on
        line([15.4,15.4],[0,g])
        hold on
        line([19.4,19.4],[0,g])
        hold on
        line([22.4,22.4],[0,g])
        hold on
        line([25.4,25.4],[0,g])
        hold on
        line([28.4,28.4],[0,g])
        hold on
        line([32.4,32.4],[0,g])
        hold on
        line([36.4,36.4],[0,g])
        hold on
        line([40.4,40.4],[0,g])
        hold on
        line([44.4,44.4],[0,g])
        hold on
        line([48.4,48.4],[0,g])
        
        ylabel('Predicted BOLD response')
        
        
    case {'K1_v1' , 'K1_v2' , 'K1_v3'}
        load v_mean_K1
        switch which_data
            case 'K1_v1'
                v_mean = v_mean_K1( 1 , : );
            case 'K1_v2'
                v_mean = v_mean_K1( 2 , : );
            case 'K1_v3'
                v_mean = v_mean_K1( 3 , : );
        end
        
        % Use bar plot to produce data
        
        b1 = bar(1:39 , v_mean);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:39,model_prediction(1:39),'filled','MarkerFaceColor', col)
        end
        legend('data' , legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(1:8, model_prediction(1:8), col );
            hold on
            plot(9:12,model_prediction(9:12), col );
            hold on
            plot(13:16, model_prediction(13:16), col );
            hold on
            plot(17:20, model_prediction(17:20), col );
            hold on
            plot(21:30, model_prediction(21:30), col );
            hold on
            plot(31:35, model_prediction(31:35), col );
            hold on
            plot(36:39, model_prediction(36:39), col );
            
        end
        
        set(gca,'xtick',[1, 9,13,17,21,31,36]);
        set(gca,'XTickLabel',{'Grating-Orientation','Grating-Contrast','Chess-Contrast','Dust-Contrast','Pattern-Contrast','Grating-Sparsity(-)','Pattern-Sparsity(-)'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        g=max(v_mean)*1.5;
        
        line([8.4,8.4],[0,g])
        hold on
        line([12.4,12.4],[0,g])
        hold on
        line([16.4,16.4],[0,g])
        hold on
        line([20.4,20.4],[0,g])
        hold on
        line([30.4,30.4],[0,g])
        hold on
        line([35.4,35.4],[0,g])
        hold on
        
        ylabel('Predicted BOLD response')
        
        % Add a title
        
    case {'K2_v1' , 'K2_v2' , 'K2_v3'}
        load v_mean_K2
        
        switch which_data
            case 'K2_v1'
                v_mean = v_mean_K2( 1 , : );
            case 'K2_v2'
                v_mean = v_mean_K2( 2 , : );
            case 'K2_v3'
                v_mean = v_mean_K2( 3 , : );
        end
        
        
        % Use bar plot to produce data
        
        b1 = bar(1:39 , v_mean);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:39,model_prediction(1:39),'filled','MarkerFaceColor', col)
        end
        legend('data',legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(1:8, model_prediction(1:8), col );
            hold on
            plot(9:12,model_prediction(9:12), col );
            hold on
            plot(13:16, model_prediction(13:16), col );
            hold on
            plot(17:20, model_prediction(17:20), col );
            hold on
            plot(21:30, model_prediction(21:30), col );
            hold on
            plot(31:35, model_prediction(31:35), col );
            hold on
            plot(36:39, model_prediction(36:39), col );
            
        end
        
        set(gca,'xtick',[1, 9,13,17,21,31,36]);
        set(gca,'XTickLabel',{'Grating-Orientation','Grating-Contrast','Chess-Contrast','Dust-Contrast','Pattern-Contrast','Grating-Sparsity(-)','Pattern-Sparsity(-)'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        g=max(v_mean)*1.5;
        
        line([8.4,8.4],[0,g])
        hold on
        line([12.4,12.4],[0,g])
        hold on
        line([16.4,16.4],[0,g])
        hold on
        line([20.4,20.4],[0,g])
        hold on
        line([30.4,30.4],[0,g])
        hold on
        line([35.4,35.4],[0,g])
        hold on
        
        ylabel('Predicted BOLD response')
        
        
    case {'K1_testSOC_v1' , 'K1_testSOC_v2' , 'K1_testSOC_v3' , 'K2_testSOC_v1' , 'K2_testSOC_v2' , 'K2_testSOC_v3'}
        load v_mean_K2
        load v_mean_K1
        switch which_data
            case 'K1_testSOC_v1'
                v_mean = v_mean_K1( 1 , 1:30 );
            case 'K1_testSOC_v2'
                v_mean = v_mean_K1( 2 , 1:30 );
            case 'K1_testSOC_v3'
                v_mean = v_mean_K1( 3 , 1:30);
            case 'K2_testSOC_v1'
                v_mean = v_mean_K2( 1 , 1:30 );
            case 'K2_testSOC_v2'
                v_mean = v_mean_K2( 2 , 1:30 );
            case 'K2_testSOC_v3'
                v_mean = v_mean_K2( 3 , 1:30);
        end
        
        % Use bar plot to produce data
        
        b1 = bar(1:30 , v_mean);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:30 ,model_prediction(1:30),'filled','MarkerFaceColor', col)
        end
        legend('data',legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(1:8, model_prediction(1:8), col );
            hold on
            plot(9:12,model_prediction(9:12), col );
            hold on
            plot(13:16, model_prediction(13:16), col );
            hold on
            plot(17:20, model_prediction(17:20), col );
            hold on
            plot(21:30, model_prediction(21:30), col );
            
            
        end
        
        set(gca,'xtick',[1, 9,13,17,21]);
        set(gca,'XTickLabel',{'Grating-Orientation','Grating-Contrast','Chess-Contrast','Dust-Contrast','Pattern-Contrast'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        g=max(v_mean)*1.5;
        
        line([8.4,8.4],[0,g])
        hold on
        line([12.4,12.4],[0,g])
        hold on
        line([16.4,16.4],[0,g])
        hold on
        line([20.4,20.4],[0,g])
        
    case { 'Ca69_target' , 'Ca05_target' }

        vec = length(t_mean_op);
        b1 = bar( t_mean_op);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:vec,model_prediction(1:vec),'filled','MarkerFaceColor', col)
        end
        legend('data', legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(1:5, model_prediction(1:5), col);
            hold on
            plot(6:vec, model_prediction(6:vec), col);
        end
        
        set(gca,'xtick',[1, 6]);
        set(gca,'XTickLabel',{'Patterns-Sparsity','Grating-Sparsity'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        g=max(t_mean_op)*1.5;
        
        line([5.4,5.4],[0,g])
        
     case { 'K1_target' , 'K2_target' }

        vec = length(t_mean_op);
        b1 = bar( t_mean_op);
        set(b1,'Facecolor', [.7, .7, .7])
        
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter(1:vec,model_prediction(1:vec),'filled','MarkerFaceColor', col)
        end
        legend('data', legend_name)
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(1:5, model_prediction(1:5), col);
            hold on
            plot(6:vec, model_prediction(6:vec), col);
        end
        
        set(gca,'xtick',[1, 6]);
        set(gca,'XTickLabel',{'Grating-Sparsity(-)','Pattern-Sparsity(-)'});
        
        h=gca;
        th=rotateticklabel(h,90);
        set (gca,'position',[0.1,0.2,.8,.75] );
        box off
        hold on
        g=max(t_mean_op)*1.5;
        
        line([5.4,5.4],[0,g])
            
        
    otherwise
        disp('Choose the right dataset')
end

end






