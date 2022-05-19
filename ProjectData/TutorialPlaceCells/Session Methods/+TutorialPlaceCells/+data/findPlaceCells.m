function varargout = findPlaceCells(sessionObject, varargin)
%FINDPLACECELLS Summary of this function goes here
%   Detailed explanation goes here


% % % % % % % % % % % % % % CUSTOM CODE BLOCK % % % % % % % % % % % % % % 
% Create a struct of default parameters (if applicable) and specify one or 
% more attributes (see nansen.session.SessionMethod.setAttributes) for 
% details.
    
    % Get struct of parameters from local function
    params = getDefaultParameters();
    
    % Create a cell array with attribute keywords
    ATTRIBUTES = {'batch', 'queueable'};   

    
% % % % % % % % % % % % % DEFAULT CODE BLOCK % % % % % % % % % % % % % % 
% - - - - - - - - - - Please do not edit this part - - - - - - - - - - - 
    
    % Create a struct with "attributes" using a predefined pattern
    import nansen.session.SessionMethod
    fcnAttributes = SessionMethod.setAttributes(params, ATTRIBUTES{:});
    
    if ~nargin && nargout > 0
        varargout = {fcnAttributes};   return
    end
    
    % Parse name-value pairs from function input.
    params = utility.parsenvpairs(params, [], varargin);
    
    
% % % % % % % % % % % % % % CUSTOM CODE BLOCK % % % % % % % % % % % % % % 
% Implementation of the method : Add your code here:    

% Get roi signals
ROIsignals = timetable2table(sessionObject.Data.RoiSignals_Dff,'ConvertRowTimes',false);
ROIsignals = table2array(ROIsignals);

% Get position signals
laps = sessionObject.Data.sData.behavior.wheelLapDsBinned;
laps = laps + 1 - min(laps);
pos = sessionObject.Data.sData.behavior.wheelPosDsBinned;

rmaps = zeros(max(laps),max(pos),size(ROIsignals,2));
for c = 1:size(ROIsignals,2)
    rmaps(:,:,c) = pipe.rmap.createRasterMap(sessionObject.Data.sData.behavior.wheelPosDsBinned,sessionObject.Data.sData.behavior.wheelLapDsBinned,ROIsignals(:,c));
end











    


end


function S = getDefaultParameters()
    
    S = struct();
    % Add more fields:

end