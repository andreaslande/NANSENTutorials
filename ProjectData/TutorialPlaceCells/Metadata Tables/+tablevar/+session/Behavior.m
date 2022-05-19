function value = Behavior(sessionObject)
%BEHAVIOR Check if behavior data exist
%   Check that the .tdms file is found in behavior data folder.
    
    % Initialize output value with the default value.
    value = false;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    
    value = length(dir(fullfile(sessionObject.DataLocation.Behavioral,'*.tdms')))>0;
    
    
end

