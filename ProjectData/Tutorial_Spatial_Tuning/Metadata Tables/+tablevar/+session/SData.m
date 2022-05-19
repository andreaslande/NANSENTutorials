function value = SData(sessionObject)
%SDATA Check if sData is created with all required fields
    
    % Initialize output value with the default value.
    value = false;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    % Get sData
    try
        % Load
        sData = sessionObject.loadData('sData');
        
        % Check for behavioral data and imaging data
        if isfield(sData.imdata,'roiSignals')
            if isfield(sData,'behavior')
                value = true;
            end
        end
     
    end
    
end

