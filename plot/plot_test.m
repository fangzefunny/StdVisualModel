function plot_test( E )


    % calculate num of stimuli
     num_stim = size( E, length(size( E)));
     stim_vec = 1:num_stim;
     
    for i = stim_vec
        subplot( 2, 5, i)
        imshow( E( :, :,  i), [] )
    end

    axis off ; 
end

