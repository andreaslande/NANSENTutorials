function value = Imaging(sessionObject)
%IMAGING Checks if imaging data exist
%  Check if the .raw file exist for given session
    
    % Initialize output value with the default value.
    value = false;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    % Check if there exist a file named .raw within the folder for raw
    % imaging data
    value = length(dir(fullfile(sessionObject.DataLocation.RawData,'*.raw')))>0;
    
end

