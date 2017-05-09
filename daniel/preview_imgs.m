% Select data subset
row = 2;
column = 4;
field = 12;
max_time = 35;
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