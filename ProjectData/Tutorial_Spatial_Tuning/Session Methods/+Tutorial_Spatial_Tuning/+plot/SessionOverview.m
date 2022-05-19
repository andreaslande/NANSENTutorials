function varargout = SessionOverview(sessionObject, varargin)
%SESSIONOVERVIEW Summary of this function goes here
%   Detailed explanation goes here


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

try
    % Get sData for session
    sData = sessionObject.loadData('sData');
    
    % Extract required data
    pos = sData.behavior.wheelPosDsBinned;
    lap = sData.behavior.wheelLapDsBinned;
    run = sData.behavior.runSpeedDs;
    deconv = sData.imdata.roiSignals(2).deconv;

    % Include only time bins where running speed is above 2 cm/s
    bins_to_include = find(run>2);

    pos = pos(bins_to_include);
    lap = lap(bins_to_include);
    deconv = deconv(:,bins_to_include);
    run = run(bins_to_include);

    % Create a rastermap of all cells 
    %rmaps = pipe.createRasterMaps(pos,lap,deconv);

    % Create rastermap of running
    run_rmap = pipe.createRasterMaps(pos,lap,run);


    % Create figure
    font_size = 16;

    figure(1); clf;
    subplot(1,2,1);
    fov_image = sData.imdata.meta.fovImageMax;
    imshow(fov_image,[min(fov_image(:)),max(fov_image(:))]);
    title(['FOV - ', sessionObject.sessionID])    
    set(gca,'FontSize',font_size)


    subplot(1,2,2)
    imagesc(smoothdata(run_rmap,'gaussian',5),[0,round(max(run_rmap(:))*1.02)]);
    c = colorbar;
    c.Label.String = "Speed (cm/s)";
    title('Running speed')
    xlabel('Position (cm)')
    ylabel('Lap #')

    xticks([1,size(run_rmap,2)])
    xticklabels([0,size(run_rmap,2)*sData.behavior.meta.binSize])

    set(gca,'FontSize',font_size)

    % Set correct size of the figure
    set(gcf,'renderer', 'painters', 'Position', [100,100,1000,400])


catch
    
end


end


function S = getDefaultParameters()
    
    S = struct();
    % Add more fields:

end