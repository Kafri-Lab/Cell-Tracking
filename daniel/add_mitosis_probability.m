
% mitosis
row = 2;
column = 4;
field = 12;
min_time = 23;
max_time = 26;
plate_region = sprintf('r%02dc%02df%02dp01', row, column, field); % example result: r02c04f12p01
rows = ResultTable.Ri==row & ResultTable.Ci==column & ResultTable.Fi==field & ResultTable.Ti<=max_time & ResultTable.Ti>=min_time;
SubsetTable = ResultTable(rows,:);

%%% DEBUG
%% LOAD NUC
channel = 3;
timepoint = 1;
filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, min_time)]; % load first image
firstImg = imread(filename,1);
nuc = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Ti)-min(SubsetTable.Ti));
nuc(:,:,1) = firstImg;
count = 1;
for i=min(SubsetTable.Ti):max(SubsetTable.Ti)
  filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  nuc(:,:,count) = imread(filename,1);
  count = count+1;
end
figure; imshow3D(nuc,[]);

%% CROP IMAGE AND DATASET TO BE SMALL ENOUGH TO DEBUG BY HAND
min_x = 500;
max_x = 700;
min_y = 600;
max_y = 800;
nuc_cropped = nuc(min_y:max_y,min_x:max_x,:);
figure; imshow3D(nuc_cropped,[]);
rows = SubsetTable.Xcoord<max_x & SubsetTable.Xcoord>min_x & SubsetTable.Ycoord>min_y & SubsetTable.Ycoord<max_y;
CroppedTable = SubsetTable(rows,:);
SubsetTable_orig = SubsetTable;
SubsetTable = CroppedTable;
nuc_orig = nuc;
nuc = nuc_cropped;
figure; imshow3D(nuc,[]);


% Dilated dots overlay
seed_mask = zeros(size(nuc));
count = 1;
for t=min(SubsetTable.Ti):max(SubsetTable.Ti)
  TableAtTime = SubsetTable(SubsetTable.Ti==t,:);
  seed_mask_slice = zeros(size(nuc,1),size(nuc,2));
  for i=1:height(TableAtTime)
    object = TableAtTime(i,:);
    seed_mask_slice(floor(object.Ycoord)-min_y,floor(object.Xcoord)-min_x)=1;
  end
  seed_mask_slice = imdilate(seed_mask_slice,strel('disk',5));
  seed_mask(:,:,count)=seed_mask_slice;
  count = count+1;
end
labelled_nuc = nuc;
labelled_nuc(seed_mask==1)=max(nuc(:));
figure; imshow3D(labelled_nuc,[]);