function sData = sDataLoad(sessionObject)
%% SDATALOAD finds and returns a sData for a session
% Returns sData structure for the given session if it exist, else it
% returns and empty struct what can be later populated with data.


% Check if SessionData folder exist, if not make it.


fullfile(sessionObject.DataLocation.ProcessedData,SessionData)





end