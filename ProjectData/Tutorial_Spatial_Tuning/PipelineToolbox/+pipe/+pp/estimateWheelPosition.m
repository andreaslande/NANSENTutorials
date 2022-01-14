function sData = estimateWheelPosition(sData)
%% ESTIMATEWHEELPOSITION 
% Estimates animals absolute position of the wheel in relation to the diode
% signal as a marker of location. 
% It also gives the number of laps that has been traversed on the track. If
% the session includes a frame onset signal, the data will be downsampled
% to match the imaging data.
% 
% INPUT/OUTPUT:
%   sData: Struct containing necessary variables. See below for required
%   input.
%
% Updated 27/09/18:
%   Now compatible with new sData standard.
%
% Written by Andreas Lande | Vervaeke Lab 2018


% PARAMETERS
radius = 25; % Radius of wheel in cm
sData.behavior.meta.binSize = 1.5; % in cm. bin size used for the binned behavior data
sData.behavior.meta.nWheelBins = 105; % Number of bins the wheel is divided into (this depends on binSize and wheel size)

% REQUIRED INPUT
w_diode = sData.daqdata.wheelDiode;
rotaryEncoderSignal = sData.daqdata.wheelRotaryEncoderSignal;
number_of_ticks = sData.daqdata.meta.wheelRotaryEncoderTicks;
bin_size = sData.behavior.meta.binSize; % Bin size used for spatially binning data
number_of_ticks = sData.daqdata.meta.wheelRotaryEncoderTicks; % Number of ticks on the rotary encoder wheel

% Turn wheel diode signal into a boolean of when it passes by
w_diode = diff([0 [w_diode]]);
w_diode(w_diode>0) = 0;
w_diode(w_diode<-0.5) = 1;
w_diode(w_diode>1) = 0;

%-- Correct the proper position
% Find first instance of the diode signal and reset wheel count accordingly
first_ind = find(w_diode);
first_ind = first_ind(1);
w_count = rotaryEncoderSignal;
w_count = w_count-w_count(first_ind);

% If there is an error with the wheel, this should be detected
if max(w_count) > 5000000
    warning('There is something wrong with the encoder wheel signal! Abnormal values detected. Proceeding anyways. But check: sData.daqdata.wheelRotaryEncoderSignal');
end

% Estimate position for each tick in relation to wheel
radius = 25; % radius of wheel in cm
circum_of_wheel_cm = (2*pi*radius); % in cm
distance_per_tick = circum_of_wheel_cm/number_of_ticks;
w_distance = w_count*distance_per_tick; % Distance measure in relation to zero point
pos = mod(w_distance,circum_of_wheel_cm); % Actual position on wheel in relation to the diode signal
lap = w_count/number_of_ticks;

% Set sData fields
sData.behavior.wheelPos = pos;
sData.behavior.wheelLap = floor(lap);

fprintf('\n ESTIMATING WHEEL POSITION\n');
fprintf('+ Position data included in sData.behavior.\n'); 

% If imaging session, downsample wheel position to frame clock 
if isfield(sData.daqdata,'frameIndex')
    % Print status
    fprintf('+ Frame onset reference detected - downsampling position and lap data to fit\n');
    sData.behavior.wheelPosDs = sData.behavior.wheelPos(sData.daqdata.frameIndex);
    sData.behavior.wheelLapDs = sData.behavior.wheelLap(sData.daqdata.frameIndex);
    
    % Downsample positions on wheel to match bin size
    % Normalize the position vector into 1 to 105, which is the bin resolution needed.
    bin_gaps = 0:bin_size:157.5;
    
    sData.behavior.wheelPosDsBinned = zeros(size(sData.behavior.wheelPosDs)); % init variable
    sData.behavior.wheelLapDsBinned = zeros(size(sData.behavior.wheelLapDs)); % init variable
    
    % Print status
    fprintf('+ Downsampling track positions to a bin size of %.2f cm\n', bin_size);
    
    % Loop through all wheel position samples and assign the new bin values
    for t = 1:length(sData.behavior.wheelPosDs)-1
        % Find the closest bin gap value
        [~,ind] = min(abs(bin_gaps-sData.behavior.wheelPosDs(t)));
        %ind = ind-1;
        sData.behavior.wheelPosDsBinned(t) = ind;
        sData.behavior.wheelLapDsBinned(t) = round(sData.behavior.wheelLapDs(t));
    end
    
    % Because 0 and 157.5 cm is the same point, the bin 1 and 106 can be merged, creating 105 bins. (??)
    sData.behavior.wheelPosDsBinned(sData.behavior.wheelPosDsBinned == 106) = 1;
    
    % Fix last index of wheelLapDsBinned
    sData.behavior.wheelLapDsBinned(end) = round(sData.behavior.wheelLapDsBinned(end));

end

% Check for errors in the binned position vector, easy fix if end index is 0
if sum(sData.behavior.wheelPosDsBinned == 0) > 0
    if sum(sData.behavior.wheelPosDsBinned == 0) == 1
        if sData.behavior.wheelPosDsBinned(end) == 0
            sData.behavior.wheelPosDsBinned(end) = sData.behavior.wheelPosDsBinned(end-1);
        end
    else
        error('More than one position bin is wrong.');
    end

end

% Set correct lap value
if min(sData.behavior.wheelLapDs) < 1
   sData.behavior.wheelLapDs = sData.behavior.wheelLapDs + abs(min(sData.behavior.wheelLapDs))+1;
end


end