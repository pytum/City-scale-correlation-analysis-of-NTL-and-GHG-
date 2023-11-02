
clear all; close all; 

if_disp = 1;
if_save = 1; 
if_plot = 1; 
if_qc_plot = 1;
if_print = 1;

% Montreal (45.50, -73.57), Ottawa (45.42, -75.70), Toronto (43.65, -79.38)
latbnd = [44, 47];[42 45]; %
lonbnd = [-76, -71]; %[-82 -77]; %
regionfix = 'montreal'; %'toronto'; %

%years = [2014:2022];
%path_data = '/Volumes/SANDISK_USB/oco2/v10/';
dataselect = 'data_analysis_test_2';
years = 2021:2023;% [2019:2022]; %
path_data = ['D:/Privat/Uni/Masterthesis/Data/GHG_data/disc_gsfc_nasa/230823/subset_OCO2_L2_Lite_FP_11.1r_20230823_193141_/',dataselect,'/'];
filesavefix = ['.',regionfix,'-',dataselect]; %
ocofix = 'oco2';

xco2 = zeros(1,0);
qc = zeros(1,0);
time = zeros(1,0);
lat = zeros(1,0);
lon = zeros(1,0);

% Get a list of files matching the pattern in the directory
file_list = dir(fullfile(path_data, [ocofix,'_LtCO2*.nc4']));

nyear = length(years);
for iyear = 1:nyear
  files_tmp = file_list([ocofix,'_LtCO2*.nc4'],path_data);
  nfile_tmp = length(files_tmp);
  for ifile = 1:nfile_tmp
    filename_tmp = files_tmp{ifile};
    if strcmp(filename_tmp(end),'*'), filename_tmp = filename_tmp(1:end-1); end
    time_tmp = netcdf_read(filename_tmp, 'time'); time_tmp = datenum(1970,01,01,0,0,time_tmp);
    lat_tmp = netcdf_read(filename_tmp, 'latitude');
    lon_tmp = netcdf_read(filename_tmp, 'longitude');
    xco2_tmp = netcdf_read(filename_tmp, 'xco2');
    qc_tmp = netcdf_read(filename_tmp, 'xco2_quality_flag');
    % selection
    idxtmp = lat_tmp >= min(latbnd) & lat_tmp <= max(latbnd) & ...
      lon_tmp >= min(lonbnd) & lon_tmp <= max(lonbnd);
    if sum(idxtmp) > 1
      if if_disp, disp([filename_tmp,': ',num2str(sum(idxtmp)),' measurements']); end
      xco2 = [xco2; xco2_tmp(idxtmp)];
      qc = [qc; qc_tmp(idxtmp)];
      time = [time; time_tmp(idxtmp)];
      lat = [lat; lat_tmp(idxtmp)];
      lon = [lon; lon_tmp(idxtmp)];
    end
  end
end

%% save
if if_save, 
  save(['oco_search',filesavefix,'.mat'],'xco2','qc','time','lat','lon','latbnd','lonbnd','years','path_data');
end


%% plot
if if_plot ~= 1,return; end

if if_qc_plot
idxqc = qc == 0;
xco2 = xco2(idxqc);
time = time(idxqc);
lat = lat(idxqc);
lon = lon(idxqc);
end

		
coast = load('coast2_hi');


% sample location
figure;
plot(coast.long,coast.lat,'.k','markersize',1);
hold on;
%plot(lon,lat,'.b');

% sample values
xmax = 430;%min(max(xco2),450);
xmin = 390;%max(min(xco2),350);
contour_range = [xmin:1:xmax];
ncolor = length(contour_range) - 1;
colormap_yih;
nx = length(xco2);
for i = 1:min([nx,1e5])
  xtmp = xco2(i);
  if xtmp > xmax, xtmp = xmax; end
  if xtmp < xmin, xtmp = xmin; end
  ic = ceil((xtmp-xmin)./(xmax-xmin).*ncolor);
  if ic == 0, ic = 1; end
  color_tmp = cmap(ic,:);
  plot(lon(i),lat(i),'.','markersize',5,'color',color_tmp);
end
colorbar_yih; 
title([ocofix,' measurements of xCO2 (ppmv)']);
set(gca,'xlim',lonbnd,'ylim',latbnd);

if if_print
  eval(['print -dpng oco_search',filesavefix,'.png']);
end

