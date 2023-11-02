% Clear all variables and close all open figures to start with a clean workspace
clear all; close all;

% Set your control variables
if_oco2 = 1;
if_qc = 1;
if_disp = 1;
if_plot = 1;
if_print = 1;

% Specify the region of interest
regionfix = 'montreal'; % or 'toronto'

% Define latitude and longitude bounds for the region of interest
latmin = 45;
latmax = 46;
lonmin = -74.5;
lonmax = -72.5;

% Load data
filename = ['oco_search.', regionfix, '-oco3-v10.mat'];
eval(['load ', filename]);
if if_oco2
    filename2 = ['oco_search.', regionfix, '-oco2-v10.mat'];
    fid = load(filename2);
    xco2 = [xco2; fid.xco2];
    qc = [qc; fid.qc];
    time = [time; fid.time];
    lat = [lat; fid.lat];
    lon = [lon; fid.lon];
end

% Filter data based on the specified latitude and longitude bounds
idxtmp = lat >= latmin & lat <= latmax & lon >= lonmin & lon <= lonmax;
xco2 = xco2(idxtmp);
qc = qc(idxtmp);
time = time(idxtmp);
lat = lat(idxtmp);
lon = lon(idxtmp);

% Apply quality control filtering if required
if if_qc
    idxqc = qc == 0;
    xco2 = xco2(idxqc);
    time = time(idxqc);
    lat = lat(idxqc);
    lon = lon(idxqc);
end

% Calculate mean XCO2 value for the entire region for each month
timemin = min(time(:));
[yyyy1, mm1, ~] = datevec(min(time(:)));
[yyyy2, mm2, ~] = datevec(max(time(:)));
nmonth = (yyyy2 - yyyy1) * 12 - (mm1 - 1) + mm2;

ts_time = repmat(NaN, [nmonth, 1]);
ts_mean = repmat(NaN, [nmonth, 1]);
ts_std = repmat(NaN, [nmonth, 1]);
ts_count = repmat(0, [nmonth, 1]);
for i = 1:nmonth
    ts_time(i) = datenum(yyyy1, mm1 + i - 1, 1);
    idxtmp = time >= ts_time(i) & time < datenum(yyyy1, mm1 + i, 1);
    if sum(idxtmp) > 0
        ts_mean(i) = mean(xco2(idxtmp));
        ts_std(i) = std(xco2(idxtmp));
        ts_count(i) = sum(idxtmp);
    end
end

% Calculate the mean of all XCO2 monthly means for the region of interest
mean_xco2_region = mean(ts_mean(~isnan(ts_mean)));

% Display the mean XCO2 value for the region
fprintf('Mean XCO2 for the region of interest: %.4f ppm\n', mean_xco2_region);

% Create a world map using the specified latitude and longitude bounds
ax = worldmap([latmin, latmax], [lonmin, lonmax]);

% Overlay the shapefile on the map (replace 'region_shapefile.shp' with your shapefile path)
shapefile = shaperead('D:/Privat/Uni/Masterthesis/Data/MTL_shp/dissolved_MTL/MTL.shp');
geoshow(shapefile);

% Overlay a single point on the map with the mean XCO2 for the region
geoshow(mean(lat), mean(lon), 'DisplayType', 'point', 'Marker', 'o', 'Color', 'red', 'MarkerSize', 10);

% Adjust the color range for the legend (modify these values as needed)
caxis([0 500]);

% Adding a colorbar
c = colorbar;
c.Label.String = 'Monthly Mean XCO2 (ppm)';

% Adding a title to the map
title(sprintf('%s: Mean XCO2 for the Region', regionfix));

% Saving the map as an image
if if_print
    eval(['print -dpng oco_mean_xco2_map.', regionfix, '.png']);
end
