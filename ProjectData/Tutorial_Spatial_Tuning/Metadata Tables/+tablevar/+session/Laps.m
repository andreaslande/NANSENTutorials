function value = Laps(sessionObject)
%LAPS Get the number of laps that is run
    
    % Initialize output value with the default value.
    value = nan;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    try
        sData = sessionObject.loadData('sData');
        value = max(sData.behavior.wheelLapDsBinned);
    end
    
    
end

