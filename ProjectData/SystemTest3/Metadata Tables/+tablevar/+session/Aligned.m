function value = Aligned(sessionObject)
%ALIGNEDBOOL Get value for AlignedBool
%   Detailed explanation goes here
    
    % Initialize output value with the default value.
    value = false;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line

    
    % Insert your code here:
    try 
        sessionObject.validateVariable('TwoPhotonSeries_Corrected');
        value = true;
    end    
    
end

