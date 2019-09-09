function E = cal_E( data, labelVec, mode, which_data )

n=128;
sfvec = 2^5/3;
o = linspace(0,pi, 9);
thetavec = o(1:end-1);
nO=length(thetavec);

[ Gabor_c, Gabor_s]=makeGaborFilter(n, sfvec, thetavec);

switch mode
    case 'orientation'
        E = zeros(8, 9, length(labelVec));
    case 'space'
        if which_data  ~= 2
            E = nan( 480, 480, nO, 9, length( labelVec ) );
        elseif which_data == 2
            E = nan( 680, 680, nO, 9, length( labelVec ) );
        end
end

idx = round((1:10)/10*length(labelVec));

fprintf('\n');
for ii= 1:length(labelVec)
    if ismember(ii, idx), fprintf('.'); end
    
    label = labelVec(ii);
    
    
    
    for ep = 1 : 9 % Each have 9 examples.
        
        % Since the dimensions are not the same
        if which_data > 2
            stimulus_i = data( : , : , ep , label );
            stimulus = imresize(stimulus_i, .5);
        else
            stimulus = data( : , : , ep, label );
        end
        
        size_s = size(stimulus , 1);
        
        
        %Pad the stimulus to avoid edge effect
        padstimulus=zeros(size_s + 80, size_s + 80);
        padstimulus(41:size_s + 40,41:size_s + 40)=stimulus;
        stimulus=padstimulus;
        
        % Filtering and rectification to get the CONTRAST of the image
        con = squeeze(Icontrast(stimulus, Gabor_c, Gabor_s, sfvec, thetavec)); %3 - D x , y , theta
        
        if strcmp( mode, 'orientation' ) == 1
            % Get the size of e_1
            size_con = size(con , 1);
            
            % Create a disk-like weight to prevent edge effect
            w = gen_disk( size( con ,  1 ) , size( con , 3 ) , 1);  %3 - D x , y , theta
            
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