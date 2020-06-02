function loss = mse( BOLD_pred, BOLD_target )

loss = mean( (BOLD_pred - BOLD_target).^2 );
end

