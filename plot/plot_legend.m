function plot_legend( all_prediction, model_ind )

nummodels = size( all_prediction ,1);
model_ind = model_ind + 1;
white = [ 0, 0, 0];
viz = ColorPalette();
dark    = viz.Dark;
blue    = viz.Blue;
red     = viz.Red;
yellow  = viz.Yellow;
green   = viz.Green;
purple  = viz.Purple;
col_vector = {white, dark, green, red, blue, yellow, purple};
legend_name = { 'BOLD', 'CE', 'NCE', 'NOA', 'SOC', 'OTS', 'NCE2'};
legend_name = legend_name(model_ind);
fontsize = 15;
plotwidth = 1.5;
markersize = 4.5;
hold on 
for i = 1:nummodels
    model_idx = model_ind(i);
    col = col_vector{model_idx};
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
