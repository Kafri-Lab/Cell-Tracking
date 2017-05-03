function zpic = im3dread(folder, imgType, plate_region, channel)
  % imgs = dir([folder '/' imgType]);
  % numImgs = size(imgs,1);
  filename = [folder sprintf('%s-ch%dsk%dfk1fl1.%s', plate_region, channel, 1, imgType)]; % load image at time 0
  firstImg = imread(filename,1);
  zpic = zeros(size(firstImg, 1), size(firstImg, 2), max(!!!!SubsetTable!!!!.Ti));
  zpic(:,:,1) = firstImg;
  for i=2:max(!!!!SubsetTable!!!!.Ti)
    filename = [folder sprintf('%s-ch%dsk%dfk1fl1.%s', plate_region, channel, i, imgType)];
    zpic(:,:,i) = imread(filename,1);
  end
end
