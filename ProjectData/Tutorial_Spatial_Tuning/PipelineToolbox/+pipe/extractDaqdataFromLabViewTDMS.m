function sData = extractDaqdataFromLabViewTDMS(sData, sessionObject)
% extractDaqdataFromLabViewTDMS Converts the TDMS data produced by labview in the
% controller PC into .csv files and extract metadata related to properties
% set in the labview code. In comparison to regular extractLabViewTDMS,
% this function stores the values at its original sampling rate, and not
% downsampled to fit with the onset of a new imaging frame.
%
% Input
%   sessionID: Classical sessionID used in the pipeline to identify the
%       session and mouse with the data.
% Output
%   metadata: structure containing all metadata obtained from the TDMS
%       file. This is iteratively find all properties set in the TDMS file
%       and assigns a subfield in the metadata struct containing the
%       property name and its corresponding value.
%
% Written by Eivind Hennestad. Rewritten to pipeline by Andreas Lande.

labviewFolder = sessionObject.DataLocation.BehavioralData;

% Find tdms file and convert to .mat file
tdmsFile = dir(fullfile(labviewFolder, '*_data.tdms'));
matFile = pipe.simpleConvertTDMS(fullfile(labviewFolder, tdmsFile(1).name));
load(matFile{1})

varPreFix = strrep([sessionObject.sessionID,'_VR'], '-', '');

% Extract property metadata from tdms file
indx = 1;
extraMetadata = struct();
extraMetadata.sessionNumber = str2num(varPreFix(end-4:end-3));

% Save all signals
while indx
    if isfield(ci.Object1,['Property' num2str(indx)])
        tmpName = ['Property' num2str(indx)];
        fieldName = ci.Object1.PropertyInfo(indx).Name;
        
        % Fix potential nameing errors
        fieldName = strrep(fieldName,' ','_');
        fieldName = strrep(fieldName,'CS+','CSpluss');
        fieldName = strrep(fieldName,'CS-','CSminus');
        fieldName = strrep(fieldName,'-','_');
        fieldName = strrep(fieldName,'(','_');
        fieldName = strrep(fieldName,')','_');
        fieldName = strrep(fieldName,'10','TEN');
        fieldName = strrep(fieldName,'20','TWENTY');
        
        property_value = ci.Object1.(tmpName).value;
        
        % Extract element from value if it is of type cell
        if iscell(property_value)
            property_value = property_value{1};
        end
        
        extraMetadata.(fieldName) = property_value;
        indx = indx+1;
    
    else
       indx = 0; 
    end
end

% Add .fs field to comply with lab standard
meta.fs = extraMetadata.Sampling_rate_downsampled;
meta.extraMetadata = extraMetadata;

% Detect all recorded channels in the TDMS file
all_vars = who;
allChannelVars = {};
channelNums = 1;

for x = 1:length(all_vars)
   if contains(all_vars(x), varPreFix)
       if strcmp(varPreFix,all_vars(x)) % Exclude empty channel
       else
           allChannelVars(channelNums) = all_vars(x);
           channelNums = channelNums+1;
          
       end
   end
end

%-- Identify frame ttl
frameIdx = [];
frameIdxDs = [];
for x = 1:length(allChannelVars)
    
    if strcmp(allChannelVars(x),[varPreFix, '2Pclock'])
        frameSignal = eval([varPreFix, '2Pclock', '.Data']);
        
        % Downsample frameSignal
        down_samp_factor = 5;
        frameSignalDs = frameSignal(1:down_samp_factor:end);
        frameIdx = find(diff(vertcat(0, frameSignal)) == 32); % This is the new frame of reference for all recorded data. This is used because the control PC actually start to sample data from for instance the running wheel before the 2P microscope starts its recording.
        frameIdxDs = find(diff(vertcat(0, frameSignalDs)) == 32);
        frameOnset = zeros(1,length(frameSignal));
        for y = frameIdx
            frameOnset(y) = 1; 
        end
    end   
end

%-- Create output struct
daqdata = struct();
daqdata.meta = meta;

% -- Use 2P frame clock as reference if this is an imaging session
dontExportFrameOnset = 0;
if isempty(frameIdx) % Not an imaging session
    frameIdx(1) = 1;
    dontExportFrameOnset = 1;
end

if dontExportFrameOnset == 1
else
    daqdata.frameOnset = frameOnset(frameIdx(1):end); % frame_onset
    daqdata.frameSignal = frameSignal(frameIdx(1):end)'; % raw frame clock signal
end

%-- Detect the present channels for this recording
for x = 1:length(allChannelVars)
   
    % Run speed channel
    if strcmp(allChannelVars(x),[varPreFix, 'Instantspeed'])
        runSpeed = eval([varPreFix, 'Instantspeed', '.Data'])';
        daqdata.runSpeed = runSpeed(frameIdx(1):end); % run_speed
    end
    
    % Wheel counter channel
    if strcmp(allChannelVars(x),[varPreFix, 'Wheel_counter'])
        wheelCounter = eval([varPreFix, 'Wheel_counter', '.Data'])';
        daqdata.wheelRotaryEncoderSignal = wheelCounter(frameIdx(1):end); % wheel_count
    elseif strcmp(allChannelVars(x),[varPreFix, 'Wheelcounter'])
        wheelCounter = eval([varPreFix, 'Wheelcounter', '.Data'])';
        daqdata.wheelRotaryEncoderSignal = wheelCounter(frameIdx(1):end); % wheel_count
    end
    
    % Wheel diode signal
    if strcmp(allChannelVars(x),[varPreFix, 'wheel_diode'])
        wheel_diode_signal = eval([varPreFix, 'wheel_diode', '.Data'])';
        daqdata.wheelDiode = wheel_diode_signal(frameIdx(1):end);
    end

    % Alternative wheel diode signal
    if strcmp(allChannelVars(x),[varPreFix, 'Photodiode'])
        photoDiode = eval([varPreFix, 'Photodiode', '.Data'])';
        daqdata.wheelDiode = photoDiode(frameIdx(1):end);  
    end
    
    % Water valve signal
    if strcmp(allChannelVars(x),[varPreFix, 'Water_valve'])
        water_valve_signal = eval([varPreFix, 'Water_valve', '.Data'])';
        daqdata.waterValveSignal = water_valve_signal(frameIdx(1):end);
    end

    % Lick signal
    if strcmp(allChannelVars(x),[varPreFix, 'Lick_signal'])
        lick_signal = eval([varPreFix, 'Lick_signal', '.Data'])';
        daqdata.lickSignal = lick_signal(frameIdx(1):end);
    end
    
        % VR position
    if strcmp(allChannelVars(x),[varPreFix, 'Position_in_VR'])
        position_in_vr = eval([varPreFix, 'Position_in_VR', '.Data'])';
        daqdata.positionInVR = position_in_vr(frameIdx(1):end);
    end
   
  
end

daqdata.frameIndex = (frameIdx-frameIdx(1)+1)';
try
    % Downsample all signals from 5000 to 1000 hz
    % Apply this to all fields in output except .meta
    fields_present = fields(daqdata);
    for x = 1:length(fields_present)
        curr_field = fields_present{x};
       if strcmp(curr_field,'meta')
       elseif (strcmp(curr_field,'frameIndex') || strcmp(curr_field,'frameOnset')) % as long as the field is not meta or frameSignal
            daqdata.frameIndex = (frameIdxDs-frameIdxDs(1)+1)';
       else   
            daqdata.(curr_field) = daqdata.(curr_field)(1:down_samp_factor:end);
       end
    end

    daqdata.meta.fs = daqdata.meta.fs / down_samp_factor;
    %fprintf('NB! Raw signals are being downsampled. See function: extractLabViewTDMS_originalFs\n');
end


% Make reference for each index to the current frame if imaging session
if isfield(daqdata,'frameOnset')

    % Make an accumulative vector containing the imaging frame number
    % at each frame onset
    frame_onset_reference_frame = zeros(1,length(daqdata.frameOnset));
    count = 1;
    for z = 1:length(daqdata.frameOnset)
        if daqdata.frameOnset(z) == 1
            frame_onset_reference_frame(z) = count;
            count = count+1;
        end
    end
    
    % Find closest frame to all
    frame_onset_closest = zeros(1,length(daqdata.frameOnset));
    distance = bwdist(frame_onset_reference_frame);
    distance = distance.*([0 diff(distance)]);
    for z = 1:length(distance)
        frame_onset_closest(z) = frame_onset_reference_frame(z-distance(z));
        if frame_onset_closest(z) == 0
            frame_onset_closest(z) = frame_onset_closest(z-1);
        end
    end
 
    daqdata.frameOnsetReferenceFrame = frame_onset_closest;

end

% Add the daqdata to sData struct
sData.daqdata = daqdata;


% -- Add session information and mouse information
%-- Add extra metadata if needed
sData.daqdata.meta.wheelRotaryEncoderTicks = 2000;

%-- Add sessionInfo
sessionName = sData.daqdata.meta.extraMetadata.name;
numIndx = findstr('-processed',sessionName);

sData.sessionInfo.sessionID = sessionObject.sessionID;
sData.sessionInfo.sessionNumber = sessionObject.sessionID(end-2:end);

sData.sessionInfo.experimentName = sData.daqdata.meta.extraMetadata.Experiment_type; 
sData.sessionInfo.date =  [sessionName(7:10),'.',sessionName(11:12),'.',sessionName(13:14)];   
sData.sessionInfo.protocol = '';               
sData.sessionInfo.recDayNumber = str2num(sessionName(numIndx-6:numIndx-4)); 
sData.sessionInfo.sessionNumber = str2num(sessionName(numIndx-2:numIndx-1));
sData.sessionInfo.sessionStartTime = sData.daqdata.meta.extraMetadata.Experiment_start_time;       % char      hh:mm:ss
sData.sessionInfo.sessionStopTime = sData.daqdata.meta.extraMetadata.Experiment_stop_time__clock_;

sData.sessionInfo.mouseWeight = [];
sData.sessionInfo.mouseOriginalWeight = [];

%-- Add mouseInfo
sData.mouseInfo.name = sessionObject.sessionID(2:5);
sData.mouseInfo.lightCycle = '10 am to 10 pm';

sData.mouseInfo.dateOfBirth = '';       % char      yyyy.mm.dd
sData.mouseInfo.strain = '';            % char      Strain of animal used. Be specific. 
sData.mouseInfo.sex = '';               % char      Male or female
sData.mouseInfo.surgeryDate = '';       % char      yyyy.mm.dd
sData.mouseInfo.windowCoordinates = []; % double	   [x, y] (mm) distance from bregma to center of window.


end