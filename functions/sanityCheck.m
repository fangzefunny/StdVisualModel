function sanityCheck(dataset, roi, etype, stimvec )

% Input 1: which datasets: dataset 1 or 2...
% Input 2: which roi area: 'v1' or 'v2' ...
% Input 3: This is prepared for arbitrary input: like two class
% Input 4: Which type of e you want to check.

% print useful information
disp(dataset)
disp(roi)

fontsize   = 12;
linewidth  = 4;
num_inrow  = 5;
set (gca, 'FontSize', fontsize, 'LineWidth', linewidth); hold on;

switch etype
    
    % case orientation
    case 'ori'
        
        % Load the E_ori
        if isnumeric(dataset)
            % load data
            fname = sprintf('E_ori_%02d.mat', dataset);
            load(fname,'E_ori');
            E_tot = squeeze( mean(E_ori, 2) );
            
            if ~isempty( stimvec )
                E_tot = E_tot( :, stimvec );
            end
            
            lenE = size( E_tot, 2 );
            nrows = floor( lenE/ num_inrow );
            
            for idx = 1:lenE
                subplot( nrows, num_inrow, idx  )
                E = E_tot( :, idx );
                plot( E )
                xlabel( 'orientation' )
                ylabel( 'response intensity' )
            end 
            
            
        end
        
        
    case 'space'
        
        
        
end




end

