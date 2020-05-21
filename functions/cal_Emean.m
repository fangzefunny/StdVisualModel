function Emean = cal_Emean( E)

n = 4;
osize = size( E, 1); 
nsize = floor( size(E, 1) / n);
Emean = nan( size(E));

for i = 1:n+1
    for j = 1:n+1
   
    x_idx = ( ( i - 1) * nsize + 1) : min(( i * nsize), osize);
    y_idx = ( ( j - 1) * nsize + 1) : min(( j * nsize), osize);
    
    x_size = min(( i * nsize), osize) - ( ( i - 1) * nsize + 1) + 1;
    y_size = min(( j * nsize), osize) - ( ( j - 1) * nsize + 1) + 1;
    
    Emean( x_idx, y_idx, :, :, :) = repmat( mean(mean(E( x_idx, y_idx, :, :, :), 2),1), [ x_size, y_size] );
    
    end
end
end