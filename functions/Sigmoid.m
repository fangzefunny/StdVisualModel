function y = Sigmoid(x)
    %{ 
        Sigmoid function:
            R --> [0,1] 
    %}
    y = 1 ./ (1 + exp(-x));

end

