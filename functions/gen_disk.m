function [w] = gen_disk(size_e, numpix)

        % Create a meshgrid to
        [X, Y] = meshgrid(linspace(-1, 1, numpix));
        
        % Create a disk with certain size
        disk = zeros(numpix, numpix);
        panel = X.^2 + Y.^2;
        
        % Choose the radius of the disk ,  3 std of the edge size 
        theresold = .75;
        
        % Any pixels 
        [index] = find(panel < theresold);
        disk(index) = 1;
        
        % pad to size_e
        pad = floor((size_e - numpix)/2);
        w = padarray(disk, [pad, pad], 0, 'both');
        % pad a 0 array to the bottom and the right
        % if size_e - numpix returns a odd number
        if size(w, 1) < size_e
            w = padarray(w, [1, 1], 0, 'post');
        end
          
end

