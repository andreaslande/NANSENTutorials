function value = Downsampled(sessionObject)
%DOWNSAMPLED Get value for Downsampled
%   Detailed explanation goes here
    
    % Initialize output value with the default value.
    value = false;                 % Please do not edit this line
    
    % Return default value if no input is given (used during config).
    if nargin < 1; return; end	% Please do not edit this line
    
    
    % Insert your code here:
    value = false;

    files = dir(fullfile(sessionObject.getDataLocation.RootPath,sessionObject.getDataLocation.Subfolders,'image_registration'));
    
    for f = 1:length(files)
        if contains(files(f).name,"two_photon_corrected_downsampled_mean_")
            value = true;
            break;
        end
    end
    
end

