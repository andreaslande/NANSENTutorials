function value = Downloaded(sessionObject)
%DOWNLOADED Get value for DataIsDownloaded
%   This functions checks to see if the larger files used for the tutorial is offline or not. 
    
    % Initialize output value with the default value.
    value = false;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    % Check if .raw exist in RawData folder
    value = ~isempty(dir(fullfile(sessionObject.DataLocation.RawData,'*.raw')));
    
 
end

