function plot_legend( all_prediction, model_ind )

nummodels = size( all_prediction ,1);
model_ind = model_ind + 1;
dark = [52, 73, 94]./255;
blue = [52, 152, 219]./255;
red = [231, 76, 60]./255;
yellow = [ 241, 196, 15]./255;
green = [46, 204, 113]./255;
col_vector = {'w', dark, green, red, blue, yellow};
col = col_vector{model_ind};
legend_name = { 'BOLD', 'CE', 'std', 'NOA','SOC', 'OTS', };
legend_name = legend_name(model_ind);
fontsize = 15;
plotwidth = 1.5;
markersize = 4.5;
hold on 
for i = 1:nummodels

%function plot_legend( )
plot( 1:2,[nan, nan], '-o',... 
    'MarkerSize', markersize,...
    'MarkerEdgeColor', col, ...
    'MarkerFaceColor', col,...
    'LineWidth', plotwidth,...
    'Color', col);

end


legend(legend_name(1:nummodels), 'Location', 'East', 'FontSize', fontsize )
axis( 'off' )
