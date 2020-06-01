%% clear the memory

clear all; close all; clc
%% hyperparameter: each time, we only need to edit this section !!

optimizer        = 'fmincon';  % what kind of optimizer, bads or fmincon . value space: 'bads', 'fmincon'
target               = 'All';              % Two target stimuli or the whole dataset. value space: 'target', 'All'
fittime              = 40;               % how many initialization. value space: Integer
data_folder    = 'noCross';  % save in which folder. value space: 'noCross', .....
cross_valiad   = 'one';           % choose what kind of cross validation, value space: 'one', 'cross_valid'. 'one' is no cross validation.

%% set path

[curPath, prevPath] = stdnormRootPath();

% add path to the function
addpath( genpath( fullfile( curPath, 'functions' )))

% add path to the model
addpath( genpath( fullfile( curPath, 'models' )))

% add path to the plot tool
addpath( genpath( fullfile( curPath, 'plot' )))

%% generate save address and  choose data

% save address? here we do not need the optimizer, 
figure_address = fullfile(curPath, 'figures', data_folder, target );
if ~exist(figure_address, 'dir'), mkdir(figure_address); end
pdf_address = fullfile(curPath, 'pdf', data_folder, target );
if ~exist(pdf_address, 'dir'), mkdir(pdf_address); end


% choose data as if we are doing parallel computing
T      = chooseData( 'orientation', optimizer, fittime );
len = size(T, 1);

%% start loop

xtick = {};
x = [1:len];
loss_bads = NaN( 1, len);
loss_fmincon = NaN( 1, len);

figure;set(gcf, 'Position', [200 100 1100 960])

for job = 1: len
    
    % obtrain data index
    dataset = T.dataset( job );
    
    % obtrain  roi index 
    roi = T.roiNum( job );
    
    % obain model index
    model_idx = T.modelNum(job);
    
    % display information to keep track
    display = [ 'dataset: ' num2str(dataset), ' roi: ',num2str( roi), ' model: ', num2str(model_idx) ];
    disp( display )
    
    % load loss record 
    loss_log = dataloader( prevPath, 'Loss_log', target, dataset, roi, data_folder , model_idx, 'bads');
    loss_bads(job) = min( loss_log);
    loss_log = dataloader( prevPath, 'Loss_log', target, dataset, roi, data_folder, model_idx, 'fmincon');
    loss_fmincon(job) = min( loss_log);
    
    xtick{end+1} = sprintf( 'D%dV%dM%d', dataset, roi, model_idx);
    
end

plot(x, loss_bads,'-o',...
             'LineWidth', 2,...
             'MarkerSize', 4,...
             'MarkerEdgeColor', 'b',...
             'MarkerFaceColor', 'b' )
hold on 
plot(x, loss_fmincon,'-o',...
             'LineWidth', 2,...
             'MarkerSize', 4,...
             'MarkerEdgeColor', 'r',...
             'MarkerFaceColor', 'r' )
 legend( 'bads', 'fmincon' )
 title( 'Compare Loss: bads vs. fmincon' )
 ylabel( 'min loss')
 set(gca, 'xtick', x);
 set(gca,'XTickLabel', xtick);
 h=gca;
th=rotateticklabel(h,60);
hold off 

% define filename and save the file
filename = fullfile( figure_address, sprintf(  '/loss_compare') );
savefig(filename)
%print
filename = fullfile( pdf_address, sprintf(  '/loss_compare')  );
print(filename,'-dpng')

%% Loss landscape
target = 'All';
dataset = 1;
 roi = 2;
 model_idx = 1;
param_pbound = [0,.2; .15,.4];
plot_loss_landscape( target, dataset, roi, model_idx, param_pbound )

