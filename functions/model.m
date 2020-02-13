classdef model
    properties (SetAccess = private)
        input1   = 1 
        input2   = 2
        IDNumber = 2
    end
    
    methods
        %init
        function obj = model( input1, input2, input3 )
            obj.input1 = input1;
            obj.input2 = input2;
            obj.input3 = input3;
        end
        
        
        function results = fit( self, input3 )
            results = self.input1 + self.input2 + input3;
        end
    end
end
    