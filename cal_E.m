function E = cal_E( data, labelVec, mode, which_data )

filter_cpd  = 3; % the images were band-passed at 3 cycles per degree
fovs        = 12.5 * [1 3/2 1 1]; % deg (the second data set had a larger field of view than the others)
fov         = fovs(which_data);
numpix      = size(data,1);
pixperdeg   = numpix / fov;
ppc         = pixperdeg/filter_cpd; % pixels per cycle
support     = 2; % cycles per filter

o = linspace(0,pi, 9);
thetavec = o(1:end-1);
nO=length(thetavec);

[ Gabor_c, Gabor_s]=makeGaborFilter(ppc, thetavec, support);

padsize = ppc * support;
sz = numpix + padsize*2;

switch mode
    case 'orientation'
        E = zeros(8, 9, length(labelVec));
    case 'space'  
        E = nan( sz, sz, nO, 9, length( labelVec ) );
end


idx = round((1:10)/10*length(labelVec));

fprintf('\n');
for ii= 1:length(labelVec)
    if ismember(ii, idx), fprintf('.'); end
    
    label = labelVec(ii);
    
    
    
    for ep = 1 : 9 % Each have 9 examples.
        
        stimulus = data( : , : , ep , label );
        
        
        %Pad the stimulus to avoid edge effect
        padstimulus=zeros(numpix + padsize*2, numpix + padsize*2);
        padstimulus(padsize+(1:numpix),padsize+(1:numpix))=stimulus;
        stimulus=padstimulus;
        
        % Filtering and rectification to get the CONTRAST of the image
        con = squeeze(Icontrast(stimulus, Gabor_c, Gabor_s, ppc, thetavec)); %3 - D x , y , theta
        
        if strcmpi( mode, 'orientation' )           
            
            % Create a disk-like weight to prevent edge effect
            w = gen_disk( size( con ,  1 ));  %3 - D x , y , theta
            
            % Calculate E_ori for orientation-type model
            % Sum over space
            E_ori = squeeze(mean(mean(w.*con , 2 ), 1)); % 1- D theta
            
            % Store the data into a matrix
            E( : ,  ep , ii ) = E_ori';
            
        elseif strcmp( mode, 'space' ) == 1
            % Calculate E_space for space-type model
            % Assign the data into a matrix
            E( : , : , : , ep , ii ) = con;
            
        end
    end
end
fprintf('\n');