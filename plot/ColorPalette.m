classdef ColorPalette
    % Define my favorite colors
   properties
        Blue        = [   9, 132, 227] / 255;
        Dark        = [  52,  73,  94] ./ 255;
        Green       = [   0, 184, 148] / 255;
        Red         = [ 255, 118, 117] / 255 .* .8;
        Yellow      = [ 253, 203, 110] / 255;
        Grey        = [ .7, .7, .7];
        Purple      = [108,  92, 231] / 255
   end
   methods
      function colors = getPalette(obj)
          %  get the palette for plot
         colors   = {obj.Dark, obj.Blue, obj.Yellow, obj.Green, obj.Red, obj.Purple};
      end
   end
end