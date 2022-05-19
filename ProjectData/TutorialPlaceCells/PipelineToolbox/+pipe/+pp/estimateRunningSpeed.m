function sData = estimateRunningSpeed(sData)
%% ESTIMATERUNNINGSPEEDS
% This is a preprocessing function which uses the wheel rotary encoder 
% signal to estimate the instantaneous running speed. A moving window is 
% applied to smooth the speed signal. 
% The running speed estimate will be added to sData.behavior.
% 
% INPUT/OUTPUT:
%   sData: Struct containing necessary variables. See below for required
%   input.
%
% Updated 27/09/18:
%   Now compatible with new sData standard.
%
% Written by Andreas Lande | Vervaeke Lab 2018

% REQUIRED INPUT
encoderSignal = sData.daqdata.wheelRotaryEncoderSignal; % Encoder signal from a rotary encoder. This is a number which increases.
fs = sData.daqdata.meta.fs; % Sampling frequency of the DAQdata signals.
number_of_ticks = sData.daqdata.meta.wheelRotaryEncoderTicks; % Number of ticks on the rotary encoder wheel

try
    frame_index = sData.daqdata.frameIndex; % (Optional) Each sample represent the sample point for each imaging frame. If this is present, a downsampled version of the runSpeed will also be added.
end

% PARAMETERS
radius = 25; % radius of wheel in cm
smoothing_window_duration = 0.1; % Seconds

% Estimate instantaneous running speed based on the counter in a optical encoder wheel.
fprintf('\nESTIMATING RUNNING SPEED\n');
wheel_movement = abs(diff(encoderSignal));
wheel_movement(wheel_movement>0) = 1; 

circum_of_wheel_cm = 2*pi*radius;% in cm
distance_per_tick = circum_of_wheel_cm/number_of_ticks;
encoderSignal = diff(encoderSignal).*distance_per_tick;

% Smoothing window
window_size = smoothing_window_duration * fs; % seconds * fs

%%-- Using a moving window averaging before y
zeropadded_count = [zeros(1,window_size) [encoderSignal]];

run_speed = zeros(size(encoderSignal));
y = 1;
for x = window_size:length(zeropadded_count)
    run_speed(y) = sum(zeropadded_count(x-window_size+1:x))/smoothing_window_duration;
    y = y + 1;
end

fprintf('+ Running speed estimated. Used 0.5 seconds moving average for smoothing.\n');

% Set new variables to sData
sData.behavior.runSpeed = run_speed;

% Downsample running speed if frame index exists (Optional)
if ~isempty(frame_index) 
   sData.behavior.runSpeedDs = run_speed(frame_index);
end

end