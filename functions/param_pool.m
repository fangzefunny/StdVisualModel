function param = param_pool( model_type, param )

switch model_type
    case 1
        
        g_mu = param(1);
        g_std = 1.5;
        n_mu = param(2);
        n_std = 1.5;
        
        g = normrnd( g_mu, g_std );
        n = normrnd( n_mu, n_std );
        
        param = [g, n];
        
    case {2, 3}
        w_mu  = param(1);
        w_std = 1.5;
        g_mu = param(2);
        g_std = 1.5;
        n_mu = param(3);
        n_std = 1.5;
        
        w = normrnd( w_mu, w_std);
        g = normrnd( g_mu, g_std );
        n = normrnd( n_mu, n_std );
        
        param = [w, g, n];
end

end