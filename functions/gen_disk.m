function [w] = gen_disk(size_e, numpix)

        scaleFactor = 0.85;
        
        % Create a meshgrid 
        [X, Y] = meshgrid(linspace(-1, 1, size_e));
        panel = sqrt(X.^2 + Y.^2); 
 
        % Create a disk
        w = zeros(size_e, size_e);
        
        radius = (numpix/size_e) * scaleFactor;
        index = panel < radius;
        w(index) = 1;
     
end
