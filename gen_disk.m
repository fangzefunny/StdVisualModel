function [ w ] = gen_disk( size_e , ep , sti)

        % Create a meshgrid to
        [ X , Y ] = meshgrid( linspace( -1 , 1, size_e));
        
        % Create a disk with certain size
        disk = zeros( size_e ,  size_e);
        panel = X.^2 + Y.^2;
        
        % Choose the radius of the disk ,  3 std of the edge size 
        theresold = (( size_e - 80 ) - 36)/size_e ;
        
        % Any pixels 
        [index] = find(panel < theresold);
        disk(index) = 1;
        
        % Create a 4-D disk ( x x y x ep x stimuli )
        for xx =1: ep
            for yy = 1:sti
            w(: , : , xx, yy) = disk;
            end
        end
   
end

