function rmap = createRasterMap(x,y,z)

% Check that all are of same length
n_bins = length(x);

% Round X and Y pos inputs and make sure they are positive values
x = round(x);
y = round(y);
if min(x) < 0; x = x + abs(min(x)) + 1; elseif min(x) < 1; x = x + 1; end
if min(y) < 0; y = y + abs(min(y)) + 1; elseif min(y) < 1; y = y + 1; end

% Create rastermap
rmap = zeros(nanmax(y),nanmax(x));
occupancymap = zeros(nanmax(y),nanmax(x));

for bin = 1:n_bins
    rmap(y(bin),x(bin)) = rmap(y(bin),x(bin)) + z(bin);
    occupancymap(y(bin),x(bin)) = occupancymap(y(bin),x(bin)) + 1;
end

% Normalize the rastermap to the occupancy in each bin
rmap = rmap./occupancymap;


end