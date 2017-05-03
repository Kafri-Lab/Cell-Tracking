  set(0,'DefaultFigureWindowStyle','docked')
addpath '\\carbon.research.sickkids.ca\rkafri\Miriam\Matlab function library'
addpath '\\carbon.research.sickkids.ca\rkafri\DanielS\cell_tracking\code\functions'

% Results table
%load('\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20170322_TG_Fibroblast_movie_2RESULTS\ResultTable.mat')

% Images path
folder = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Raw Data\Mammalian cells\20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1\Images\'


row = 2;
column = 4;
field = 12;
max_time = 6;
rows = ResultTable.Ri==row & ResultTable.Ci==column & ResultTable.Fi==field & ResultTable.Ti<max_time;
SubsetTable = ResultTable(rows,:);
plate_region = 'r02c04f12p01';

%% LOAD NUC
channel = 3;
t = 1;
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

%% Dots overlay
labelled_nuc = nuc;
for t=1:max(SubsetTable.Ti)
  TableAtTime = SubsetTable(SubsetTable.Ti==t,:);
  for i=1:height(TableAtTime)
    object = TableAtTime(i,:);
    labelled_nuc(floor(object.Ycoord),floor(object.Xcoord),t)=max(nuc(:));
  end
end
figure; imshow3D(labelled_nuc,[]);

% Dilated dots overlay
seed_mask = zeros(size(nuc));
for t=1:max(SubsetTable.Ti)
  TableAtTime = SubsetTable(SubsetTable.Ti==t,:);
  seed_mask_slice = zeros(size(nuc,1),size(nuc,2));
  for i=1:height(TableAtTime)
    object = TableAtTime(i,:);
    seed_mask_slice(floor(object.Ycoord),floor(object.Xcoord))=1;
  end
  seed_mask_slice = imdilate(seed_mask_slice,strel('disk',5));
  seed_mask(:,:,t)=seed_mask_slice;
end
labelled_nuc = nuc;
labelled_nuc(seed_mask==1)=max(nuc(:));
figure; imshow3D(labelled_nuc,[]);

%% Overlay text2im
labelled_nuc = nuc;
for t=1:max(SubsetTable.Ti)
  ObjectsInFrame = SubsetTable(SubsetTable.Ti==t,:);
  seed_mask_slice = zeros(size(nuc,1),size(nuc,2));
  for i=1:height(ObjectsInFrame)
    Object = ObjectsInFrame(i,:);
    x = floor(Object.Ycoord);
    y = floor(Object.Xcoord);
    trace_id=0;
    trace_id_im = text2im(num2str(Object.TraceID));
    trace_id_im = imresize(trace_id_im ,1);
    labelled_nuc(x:x-1+size(trace_id_im,1),y:y-1+size(trace_id_im,2),t)=trace_id_im*max(nuc(:)); % overlay text
  end
end
figure; imshow3D(labelled_nuc,[]);

