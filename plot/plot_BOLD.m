function figureM1=plot_BOLD(dataset, roi, all_prediction, legend_name , t_mean_op)

% Create a figure to carry the plot
%figureM1=figure('units', 'normalized', 'outerposition', [0.1 0.05 .6 .85], 'color',[1 1 1]);

% Colors for each model
col_vector = {'k' , 'r' , 'g' , 'b' , 'y','m'};

fontsize = 12;

linewidth = 4;

markersize = 100; 

set (gca, 'FontSize', fontsize, 'LineWidth', linewidth); hold on;

% Load the data to see how the data looks like
if isnumeric(dataset)
    fname = sprintf('dataset%02d.mat', dataset);
    load(fname, 'v_mean');
    v_mean = v_mean(roi, : );
end

switch dataset
    
    case 1                        
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
        th=rotateticklabel(h,45);
        %set (gca,'position',[0.1,0.2,.8,.75] );
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
        
        
        
    case 2
        
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
        set(gca,'XTickLabel',{('Patterns-Sparsity'),'Grating-Sparsity','NoiseBars-Sparsity','Waves-Sparisity','Grating-Orientation','Noisebar-Orientation','Waves-Orientation','Grating-cross','Grating-Contrast','Noisebar-Contrast','Wave-Contrast','Pattern-Contrast'});
        
        h=gca;
        th=rotateticklabel(h,90);
        %set (gca,'position',[0.1,0.2,.8,.75] );
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
        
        
    case 3
        
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
        %set (gca,'position',[0.1,0.2,.8,.75] );
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
      legend('data' , legend_name, 'Location', 'EastOutside')
        
        % Add a title
        
    case 4
        
        
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
        %set (gca,'position',[0.1,0.2,.8,.75] );
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
                
%                 
    case { '1_target' , '2_target' '3_target' , '4_target' }
                                
        switch dataset 
            case { '1_target' , '2_target'} 
                x1 = 1:5;  y1 = 1:5;
                x2 = 6:10; y2 = 6:10;
            case { '3_target' , '4_target'} 
                x1 = 1:4; y1 = 9:-1:6;
                x2 = 5:9; y2 = 5:-1:1;                
        end
        
        
        b1 = bar(x1, t_mean_op(y1)); hold on
        b2 = bar(x2, t_mean_op(y2));
        set(b1,'Facecolor', [86 44 136]/255);% [.7, .7, .7])
        set(b2,'Facecolor', [66 140 203]/255);% [.7, .7, .7])
        hold on
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            scatter([x1 x2],model_prediction([y1 y2]),...
                ... markersize, 'filled','MarkerFaceColor', col )
                markersize,  col, 'LineWidth', linewidth )
        end
        
        for which_prediction = 1:size( all_prediction ,2)
            model_prediction = all_prediction(  : , which_prediction );
            model_prediction = model_prediction';
            col = col_vector{which_prediction};
            hold on
            plot(x1, model_prediction(y1), col, 'LineWidth', linewidth);
            hold on
            plot(x2, model_prediction(y2), col, 'LineWidth', linewidth);
        end
        
        set(gca,'xtick',[mean(x1), mean(x2)]);
        set(gca,'XTickLabel',{'Patterns-Sparsity','Grating-Sparsity'});
        
        h=gca;
        th=rotateticklabel(h,15);
        %set (gca,'position',[0.1,0.2,.8,.75] );
        box off
             
    otherwise
        disp('Choose the right dataset')
end

% Add a title
% ylabel('Predicted BOLD response')
legend('data', legend_name, 'Location', 'EastOutside')

end






