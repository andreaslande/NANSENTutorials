function rmaps = createRasterMaps(x,y,signal)
%% CREATERASTERMAPS Creates rastermap(s).
%
% INPUT
%   x: x position. Array of shape: 1 x m.
%   y: y position. Array of shape: 1 x m.
%   signal: the signal to be plotted at each (x,y) position. Shape: n x m,
%       where n is the number of signals, and m is an array that matches the
%       length of x and y.
%
% OUTPUT
%   rmap: rastermap(s) of the data.


% Check that inputs are correct
% Round X and Y pos inputs and make sure they are positive values
x = round(x);
y = round(y);
if min(x) < 0; x = x + abs(min(x)) + 1; elseif min(x) < 1; x = x + 1; end
if min(y) < 0; y = y + abs(min(y)) + 1; elseif min(y) < 1; y = y + 1; end

% Find the dimensions of the rastermap
x_max = max(x);
y_max = max(y);
n_maps = size(signal,1); % Number of signals to be used

% Specify number of samples
n_samples = length(x);

% Create rastermap
rmaps = zeros(y_max, x_max, n_maps); % init rmaps to be created
posmap = zeros(y_max, x_max, n_maps); % init position maps to be used for normalize the rmaps to number of visits in each x, y position.

for n = 1:n_maps % For each map  
    for t = 1:n_samples % For each data sample
        x_val = x(t);
        y_val = y(t);
        rmaps(y_val,x_val,n) = rmaps(y_val,x_val,n) + signal(n,t); % Add the signal to rmap
        posmap(y_val,x_val,n) = posmap(y_val,x_val,n) + 1; % Increment this X,Y position with 1 "visit".
    end
end

% Create a position normalized rastermap
rmaps = (rmaps./posmap); 



end