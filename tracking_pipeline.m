set(0,'DefaultFigureWindowStyle','docked')
addpath(genpath('functions'))


% Results table (Ron)
data_path = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20171103_RB_LFS__2017_11_03T17_30_39RESULTS\ResultTable - 2 wells, 2 fields, thresh 160.mat';
% Results table (Heather)
% data_path = '\\carbon.research.sickkids.ca\rkafri\Heather\ResultsTables\Dataset_20170322_TG_Fibroblast_movie_2RESULTS\ResultTable.mat';

%% LOAD DATA
fprintf('Loading data from "%s"...\n', data_path);
load(data_path);

% Images path
folder = 'Z:\OPRETTA\Operetta Raw Data\Mammalian cells\20171103_RB_LFS__2017-11-03T17_30_39-Measurement1\Images\';

% Select data subset (only for quicker testing/debugging)
row = 5;
column = 7;
field = 19;
min_time = 1;
max_time = 193;
plate_region = sprintf('r%02dc%02df%02dp01', row, column, field); % example result: r02c04f12p01
rows = ResultTable.Row==row & ResultTable.Column==column & ResultTable.Field==field & ResultTable.Time<=max_time & ResultTable.Time>=min_time;
SubsetTable = ResultTable(rows,:);
if height(SubsetTable) == 0
    error('Exiting... No cells found at the given combination of time, row, column, and field');
end
SubsetTable.TraceUsed(:,1)=0;
fprintf('Operating on:\n\trow = %d\n\tcolumn = %d\n\tfield = %d\n\tmin_time = %d\n\tmax_time = %d\n',row, column, field, min_time, max_time)

%% LOAD NUC
fprintf('Loading NUC images...\n')
channel = 1;
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
fprintf('Loading CYTO images...\n')
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
%figure; imshow3D(cyto,[]);

%% CROP IMAGE AND DATASET TO BE SMALL ENOUGH TO DEBUG BY HAND
% if exist('nuc_orig')
%   nuc = nuc_orig;
% end
% if exist('SubsetTable_orig')
%   SubsetTable = SubsetTable_orig;
% end
% min_x = 1100;
% max_x = 1280;
% min_y = 580;
% max_y = 750;
% nuc_cropped = nuc(min_y:max_y,min_x:max_x,:);
% figure; imshow3D(nuc_cropped,[]);
% rows = SubsetTable.Centroid(:,1)<max_x & SubsetTable.Centroid(:,1)>min_x & SubsetTable.Centroid(:,2)>min_y & SubsetTable.Centroid(:,2)<max_y;
% CroppedTable = SubsetTable(rows,:);
% if height(SubsetTable) == 0
%     error('Exiting... No cells found at the given combination of time, row, column, and field');
% end
% CroppedTable.Centroid(:,1) = CroppedTable.Centroid(:,1) - min_x;
% CroppedTable.Centroid(:,2) = CroppedTable.Centroid(:,2) - min_y;
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
[SubsetTable,DiffTable] = cell_tracking_v1_simple(SubsetTable, composite_differences);


%% DEBUG
%labelled_imgs = overlay_trace_ids_on_imgs(SubsetTable, nuc);
coloured_imgs = overlay_nuc_and_nuc(SubsetTable, cyto);
colour_imgs_to_gif(coloured_imgs);
% imgs_to_gif(labelled_imgs);

%% SAVE DATA
[data_filepath,data_name,data_ext] = fileparts(data_path);
output_path = sprintf('%s/%s_with_Traces.mat',data_filepath,data_name);
fprintf('Saving results to "%s"\n', output_path)
save(output_path,'SubsetTable');

% PLOT
% frame_to_frame_changes(SubsetTable);