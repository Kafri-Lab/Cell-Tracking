set(0,'DefaultFigureWindowStyle','docked')
addpath 'functions'

% Results table
load('R:\Heather\ResultsTables\Dataset_20170322_TG_Fibroblast_movie_2RESULTS\ResultTable.mat')

% Images path
folder = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Raw Data\Mammalian cells\20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1\Images\';

% Select data subset (only for quicker testing/debugging)
row = 2;
column = 5;
field = 10;
min_time = 1;
max_time = 50;
plate_region = sprintf('r%02dc%02df%02dp01', row, column, field); % example result: r02c04f12p01
rows = ResultTable.Row==row & ResultTable.Column==column & ResultTable.Field==field & ResultTable.Time<=max_time & ResultTable.Time>=min_time;
SubsetTable = ResultTable(rows,:);
if height(SubsetTable) == 0
    error('Exiting... No cells found at the given combination of time, row, column, and field');
end

%% LOAD NUC
channel = 3;
timepoint = 1;
filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, min_time)]; % load first image
firstImg = imread(filename,1);
nuc = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Time)-min(SubsetTable.Time));
nuc(:,:,1) = firstImg;
count = 1;
for i=min(SubsetTable.Time):max(SubsetTable.Time)
  filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  nuc(:,:,count) = imread(filename,1);
  count = count+1;
end
%figure; imshow3D(nuc,[]);

% %% LOAD CYTO
channel = 1;
t = 1;
filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, min_time)]; % load image at time 0
firstImg = imread(filename,1);
cyto = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Time));
cyto(:,:,1) = firstImg;
for i=2:max(SubsetTable.Time)
  filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  cyto(:,:,i) = imread(filename,1);
end
% figure; imshow3D(cyto,[]);

%% CROP IMAGE AND DATASET TO BE SMALL ENOUGH TO DEBUG BY HAND
% min_x = 1100;
% max_x = 1280;
% min_y = 580;
% max_y = 750;
% nuc_cropped = nuc(min_y:max_y,min_x:max_x,:);
% figure; imshow3D(nuc_cropped,[]);
% rows = SubsetTable.Xcoord<max_x & SubsetTable.Xcoord>min_x & SubsetTable.Ycoord>min_y & SubsetTable.Ycoord<max_y;
% CroppedTable = SubsetTable(rows,:);
% CroppedTable.Xcoord = CroppedTable.Xcoord - min_x;
% CroppedTable.Ycoord = CroppedTable.Ycoord - min_y;
% SubsetTable_orig = SubsetTable;
% SubsetTable = CroppedTable;
% nuc_orig = nuc;
% nuc = nuc_cropped;
% figure; imshow3D(nuc,[]);

% Calc x and y cell locations
Ycoord = SubsetTable.Centroid(:,2);
Xcoord = SubsetTable.Centroid(:,1);
x = floor(Ycoord);
y = floor(Xcoord);
SubsetTable.Xcoord = x;
SubsetTable.Ycoord = y;
    
%% CALC DIFFERENCES BETWEEN FRAMES
[raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(SubsetTable);

%% TRACK CELLS
SubsetTable = cell_tracking_v1_simple(SubsetTable, composite_differences);

%% DEBUG
labelled_imgs = overlay_trace_ids_on_imgs(SubsetTable, nuc);
coloured_imgs = overlay_nuc_and_nuc(SubsetTable, cyto);
colour_imgs_to_gif(coloured_imgs);
imgs_to_gif(labelled_imgs);

