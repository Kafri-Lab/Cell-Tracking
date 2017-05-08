set(0,'DefaultFigureWindowStyle','docked')
addpath '\\carbon.research.sickkids.ca\rkafri\Miriam\Matlab function library'
addpath '\\carbon.research.sickkids.ca\rkafri\DanielS\cell_tracking\code\functions'

% Results table
%load('\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20170322_TG_Fibroblast_movie_2RESULTS\ResultTable.mat')

% Images path
folder = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Raw Data\Mammalian cells\20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1\Images\';

% Select data subset
row = 2;
column = 4;
field = 12;
max_time = 6;
plate_region = sprintf('r%02dc%02df%02dp01', row, column, field); % example result: r02c04f12p01
rows = ResultTable.Ri==row & ResultTable.Ci==column & ResultTable.Fi==field & ResultTable.Ti<max_time;
SubsetTable = ResultTable(rows,:);

%% LOAD NUC
channel = 3;
timepoint = 1;
filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, timepoint)]; % load image at time 0
firstImg = imread(filename,1);
nuc = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Ti));
nuc(:,:,1) = firstImg;
for i=2:max(SubsetTable.Ti)
  filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  nuc(:,:,i) = imread(filename,1);
end
figure; imshow3D(nuc,[]);

%% LOAD CYTO
channel = 1;
t = 1;
filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, timepoint)]; % load image at time 0
firstImg = imread(filename,1);
cyto = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Ti));
cyto(:,:,1) = firstImg;
for i=2:max(SubsetTable.Ti)
  filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  cyto(:,:,i) = imread(filename,1);
end
figure; imshow3D(cyto,[]);

%% CROP IMAGE AND DATASET TO BE SMALL ENOUGH TO DEBUG BY HAND
crop_amount=350;
nuc_cropped = nuc(1:crop_amount,1:crop_amount,:);
figure; imshow3D(nuc_cropped,[]);
rows = SubsetTable.Xcoord<crop_amount & SubsetTable.Ycoord<crop_amount;
CroppedTable = SubsetTable(rows,:);
SubsetTable_orig = SubsetTable;
SubsetTable = CroppedTable;
nuc_orig = nuc;
nuc = nuc_cropped;

%% CALC DIFFERENCES BETWEEN FRAMES
[raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(SubsetTable);

%% TRACK CELLS
SubsetTable = cell_tracking_v1_simple(SubsetTable, composite_differences);

%% DEBUG
labelled_imgs = overlay_trace_ids_on_imgs(SubsetTable, nuc);
imgs_to_gif(labelled_imgs);