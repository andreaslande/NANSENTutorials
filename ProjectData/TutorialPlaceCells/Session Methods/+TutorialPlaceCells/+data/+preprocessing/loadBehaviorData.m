function varargout = loadBehaviorData(sessionObject, varargin)
%LOADBEHAVIORDATA Loads labview TDMS file and saves behavioral data.
%   Load labview TDMS where the data aqcuisition data from LabView is
%   stored. This is saved as a subfield into 

% % % % % % % % % % % % % % CUSTOM CODE BLOCK % % % % % % % % % % % % % % 
% Create a struct of default parameters (if applicable) and specify one or 
% more attributes (see nansen.session.SessionMethod.setAttributes) for 
% details.
    
    % Get struct of parameters from local function
    params = getDefaultParameters();
    
    % Create a cell array with attribute keywords
    ATTRIBUTES = {'serial', 'unqueueable'};   

    
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

% Localize the TDMS file
tdms_filepath = dir(fullfile(sessionObject.getSessionFolder('Behavioral'),'*.tdms'));

% If the file exist
if ~isempty(tdms_filepath)

    % Get full path
    tdms_filepath = fullfile(tdms_filepath.folder,tdms_filepath.name);

    % -- All data will be stored in a MATLAB structed called sData (short for session data)
    % Load sData if it exists (else return empty sData struct)
    try
        sData = sessionObject.loadData('sData');
    catch
        sData = struct();
    end

    % Load daqdata into sData
    sData = pipe.extractDaqdataFromLabViewTDMS(sData, sessionObject);
   
    % Estimate running speed
    sData = pipe.pp.estimateRunningSpeed(sData);
    
    % Estimate wheel position and bin the positions along the linear track
    sData = pipe.pp.estimateWheelPosition(sData); 

    % Save the updated sData
    sessionObject.saveData('sData',sData)

end

end


function S = getDefaultParameters()
    
    S = struct();
    % Add more fields:

end
