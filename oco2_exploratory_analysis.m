clear all; close all; 

path = 'D:/Privat/Uni/Masterthesis/Data/GHG_data/disc_gsfc_nasa/040923/data_analysis_test_2_matlab/';
filename = 'D:/Privat/Uni/Masterthesis/Data/GHG_data/disc_gsfc_nasa/040923/data_analysis_test_2_matlab/oco2_LtCO2_220901_B11100Ar_230609082353s.nc4';

time = ncread(filename, 'time'); time = datenum(1970,01,01,0,0,time);
lat = ncread(filename, 'latitude');
lon = ncread(filename, 'longitude');

xco2 = ncread(filename, 'xco2');
nx = length(xco2);
xmax = 410;%min(max(xco2),450);
xmin = 390;%max(min(xco2),350);


% Specify the path to your coastline shapefile
coastlineShapefilePath = ('D:/Privat/Uni/Masterthesis/Data/GHG_data/disc_gsfc_nasa/040923/data_analysis_test_2_matlab/ne_10m_coastline.shp');

% Read the coastline shapefile
coast = shaperead(coastlineShapefilePath);

% Plot the coastline
figure;
for i = 1:length(coast)
    plot(coast(i).X, coast(i).Y, '-k');
    hold on;
end

% sample location
figure;
for i = 1:length(coast)
    line(coast(i).X, coast(i).Y, 'Color', 'k');
    hold on;
end

% sample values
contour_range = [xmin:1:xmax];
ncolor = length(contour_range) - 1;
cmap = jet(ncolor);  % Using MATLAB's 'jet' colormap
for i = 1:nx
    xtmp = xco2(i);
    if xtmp > xmax, xtmp = xmax; end
    if xtmp < xmin, xtmp = xmin; end
    ic = ceil((xtmp - xmin) / (xmax - xmin) * ncolor);
    if ic == 0, ic = 1; end
    color_tmp = cmap(ic, :);
    plot(lon(i), lat(i), '.', 'markersize', 5, 'color', color_tmp);
end
colorbar;

title(['oco2 measurements of xCO2 (ppmv) on ', datestr(datenum(2017, 01, 01), 'yyyy-mm-dd')]);

print -dpng oco2_firstlook_20170101.png;