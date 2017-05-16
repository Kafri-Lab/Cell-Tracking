runtimes = [];
loops = 1:10:91;

for num_imgs=loops
  tic
  set(0,'DefaultFigureWindowStyle','docked')
  addpath 'functions'

  % Results table
  %load('\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20170322_TG_Fibroblast_movie_2RESULTS\ResultTable.mat')

  % Images path
  folder = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Raw Data\Mammalian cells\20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1\Images\';

  % Select data subset
  row = 2;
  column = 4;
  field = 12;
  min_time = 1;
  max_time = num_imgs;
  plate_region = sprintf('r%02dc%02df%02dp01', row, column, field); % example result: r02c04f12p01
  rows = ResultTable.Ri==row & ResultTable.Ci==column & ResultTable.Fi==field & ResultTable.Ti<=max_time & ResultTable.Ti>=min_time;
  SubsetTable = ResultTable(rows,:);

  %% LOAD NUC
  % channel = 3;
  % timepoint = 1;
  % filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, min_time)]; % load first image
  % firstImg = imread(filename,1);
  % nuc = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Ti)-min(SubsetTable.Ti));
  % nuc(:,:,1) = firstImg;
  % count = 1;
  % for i=min(SubsetTable.Ti):max(SubsetTable.Ti)
  %   filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  %   nuc(:,:,count) = imread(filename,1);
  %   count = count+1;
  % end
  % figure; imshow3D(nuc,[]);

  % %% LOAD CYTO
  % channel = 1;
  % t = 1;
  % filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, timepoint)]; % load image at time 0
  % firstImg = imread(filename,1);
  % cyto = zeros(size(firstImg, 1), size(firstImg, 2), max(SubsetTable.Ti));
  % cyto(:,:,1) = firstImg;
  % for i=2:max(SubsetTable.Ti)
  %   filename = [folder sprintf('%s-ch%dsk%dfk1fl1.tiff', plate_region, channel, i)];
  %   cyto(:,:,i) = imread(filename,1);
  % end
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

  % ADD MITOSIS
  SubsetTable.Mitosis = zeros(height(SubsetTable),1);

  %% CALC DIFFERENCES BETWEEN FRAMES
  [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(SubsetTable);

  %% TRACK CELLS
  SubsetTable = cell_tracking_v1_simple(SubsetTable, composite_differences);

  %% DEBUG
  %labelled_imgs = overlay_trace_ids_on_imgs(SubsetTable, nuc);
  %imgs_to_gif(labelled_imgs);

  elapsedTime = toc;
  runtimes = [runtimes elapsedTime]
end
% runtimes = [0.2010 1.4749 2.0764 2.8508 3.9125 4.5440 5.7475 7.1131 8.6430 9.2701]
figure;
plot(loops,runtimes,'b');
P = polyfit(loops,runtimes,1);
loops2 = 1:10:901;
yfit = P(1)*loops2+P(2);
hold on;
plot(loops2,yfit,'r-.');
legend('actual','predicted');
title('Cell Tracker Algorithm Efficiency')
xlabel('Images in Timelapse')
ylabel('Run Time (s)')
xlim([0 1000])
ylim([0 50])
