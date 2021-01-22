%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot' )))

%% figure 1 

grating_cl = [ .8, .8, .8];
pattern_cl = [ .6, .6, .6];
x_pattern = 1:5;
x_grating = 7:11;

% set the figure size
% the figure size is design to have 1.5 col width
set( gcf, 'unit', 'centimeters', 'position', [10, 5, 8.5, 16]);
set( gca, 'FontSize', 9) 


for roi = 1:3
    
    subplot( 3, 1, roi)
    
    BOLD_target = dataloader( curPath, 'BOLD_target', 'target', 1, roi );
    BOLD_target_error = dataloader( curPath, 'BOLD_target_error', 'target', 1, roi);
    
    bar( x_pattern, ...
         BOLD_target( 1: 5), ...
         'FaceColor', pattern_cl, ...
         'EdgeCoLor', pattern_cl);
    hold on 
    bar( x_grating, ...
         BOLD_target( 6: 10), ...
         'FaceColor', grating_cl, ...
         'EdgeCoLor', grating_cl);
    
    errorbar( x_pattern, ...
              BOLD_target( 1: 5), ...
              BOLD_target_error( 1: 5), ...
              BOLD_target_error( 1: 5), ...
              'LineStyle', 'none', ...
              'Color', 'k');
          
    errorbar( x_grating, ...
              BOLD_target( 6: 10), ...
              BOLD_target_error( 6: 10), ...
              BOLD_target_error( 6: 10), ...
              'LineStyle', 'none', ...
              'Color', 'k');
     
     
    show_title = sprintf( 'V%d', roi );
    set(gca,'XTick', []);
    ylim( [ 0, 1.5])
    box off
    
end

%% figure 2a 




%% figure 2

% figure;
% for stim = 4
%     subplot( 2,5, stim)
%     stimuli = dataloader( prevPath, 'stimuli', 'target', 1, roi );
%     stimulus = stimuli( :, :, 4, stim);
%     imshow( stimulus, [])
% end
% 
% which_data  = 1;
% filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
% fovs        = 12.5 * [1, 3/2, 1, 1]; % deg (the second data set had a larger field of view than the others)
% fov         = fovs(which_data);
% numpix      = size(stimulus,1);
% pixperdeg   = numpix / fov;
% ppc         = pixperdeg/filter_cpd; % pixels per cycle
% support     = 2; % cycles per filter
% 
% o = linspace(0,pi, 9);
% thetavec = o(1:end-1);
% nO=length(thetavec);
% 
% [ Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);
% 
% padsize = ppc * support;
% sz = numpix + padsize*2;
% 
%  %Pad the stimulus to avoid edge effect
% padstimulus=zeros(numpix + padsize*2, numpix + padsize*2);
% padstimulus(padsize+(1:numpix),padsize+(1:numpix))=stimulus;
% stimulus=padstimulus;
% 
% con = squeeze(Icontrast(stimulus, Gabor_c, Gabor_s, ppc, thetavec));
% figure;
% E = sum( con, 3);
% imshow( E, [])


