function plot_legend( all_prediction )

nummodels = size( all_prediction ,2);

dark = [52, 73, 94]./255;
blue = [52, 152, 219]./255;
red = [231, 76, 60]./255;
yellow = [ 241, 196, 15]./255;
green = [46, 204, 113]./255;
col_vector = {dark, red, green};%dark, blue, yellow, red, green
legend_name = {  'contrast', 'soc', 'oriSurround', 'normVar' };
fontsize = 15;
plotwidth = 1.5;
markersize = 4.5;
hold on 
for i = 1:nummodels
col = col_vector{i};
%function plot_legend( )
plot( 1:2,[nan, nan], '-o', 'MarkerSize', markersize,...
                                                                      'MarkerEdgeColor', col, ...
                                                                      'MarkerFaceColor', col,...
                                                                      'LineWidth', plotwidth,...
                                                                       'Color', col);

end


legend(legend_name(1:nummodels), 'Location', 'West', 'FontSize', fontsize )
axis( 'off' )
