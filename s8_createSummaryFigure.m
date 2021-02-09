%% load stimuli and data
load(fullfile(stdnormRootPath, 'Data', 'Stimuli','stimuli-dataset01.mat'), 'stimuli');
load(fullfile(stdnormRootPath, 'Data','E', 'E_ori_01.mat'), 'E_ori');

%% look at stimuli
figure(1); clf
for ii = 1:50
    subplot(5,10,ii); imshow(stimuli(:,:,1,ii)+0.5);title(ii)
end

%%
figure(2) , clf ; set(gcf, 'Color', 'w', 'Position', [1 1 700 800])
w = [51 129 192]; % V1 V2 V3
w = w(2);
fs = 12;
pattern = 0.6 * [1 1 1];
grating = 0.8 * [1 1 1];

toplot = [35:38 47:50];
toplot = [36 38 48 50];
toplot = [50 38 36]; colors = [pattern; grating; grating];
n = length(toplot);

for ii = 1:n
   idx = toplot(ii);
   
   mn_o = mean(E_ori(:,:,idx),2);
   vr_o = var(mn_o);

   subplot(n,3,(ii-1)*3+1), imshow(squeeze(stimuli(:,:,1,idx))+0.5)   
   
   subplot(n,3,(ii-1)*3+2), bar(mn_o, 'FaceColor', colors(ii,:)); 
   set(gca, 'FontSize', fs, 'YTick', 0:.1:.3, 'XTick', [])
   ylim([0 .3]);    
   str = sprintf('Sum = %3.2f\nVar = %5.4f', sum(mn_o), vr_o);   
   text(0.2, .25, str, 'FontSize', fs);
   box off;
   if ii == 1, title('Contrast Energy'), end
   
   subplot(n,3,(ii-1)*3+3), bar(mn_o./(1+w*vr_o), 'FaceColor', colors(ii,:)); 
   set(gca, 'FontSize', fs, 'YTick', 0:.1:.3, 'XTick', [])
   ylim([0 .3]);
   str = sprintf('Sum = %3.2f\n', sum(mn_o)/(1+w*vr_o));
   text(0.2, .25, str, 'FontSize', fs);
   box off;
   if ii == 1, title('Normalized Energy'), end
end
hgexport(gcf, fullfile(stdnormRootPath, 'figures','model_demo_fig7.eps'));
