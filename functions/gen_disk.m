function [ w ] = gen_disk( size_e)

        % Create a meshgrid to
        [ X , Y ] = meshgrid( linspace( -1 , 1, size_e));
        
        % Create a disk with certain size
        w = zeros( size_e ,  size_e);
        panel = X.^2 + Y.^2;
        
        % Choose the radius of the disk ,  3 std of the edge size 
        theresold = .75;
        
        % Any pixels 
        [index] = find(panel < theresold);
        w(index) = 1;
     
end

