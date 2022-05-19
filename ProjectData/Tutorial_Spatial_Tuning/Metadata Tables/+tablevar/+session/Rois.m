function value = Rois(sessionObject)
%ROIS Get value for NRois
%   Detailed explanation goes here
    
    % Initialize output value with the default value.
    value = nan;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    
    try
        sData = sessionObject.loadData('sData');

        % Get number of ROIs
        value = size(sData.imdata.roiSignals(2).roif,1);
    end
    
end

