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

% diff_measurements = DiffMeasurements(SubsetTable);
%% Calc Differetial Measurements between T and T+1
raw_differences = {};
for t=1:max(SubsetTable.Ti)-1
  T1 = SubsetTable(SubsetTable.Ti==t,:);
  T2 = SubsetTable(SubsetTable.Ti==t+1,:);

  % Tranlation distances between T and T+1
  X_translation = squareform(pdist([T1.Xcoord;T2.Xcoord]));
  X_translation=X_translation(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing translation
  Y_translation = squareform(pdist([T1.Ycoord;T2.Ycoord]));
  Y_translation=Y_translation(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing translation
  [theta,rho] = cart2pol(X_translation,Y_translation);
  raw_differences{t}.Translation = rho;

  % Eccentricity differences
  eccentricity_diff = squareform(pdist([T1.Eccentricity;T2.Eccentricity]));
  raw_differences{t}.Eccentricity = eccentricity_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

  % Nuclear area differences
  area_diff = squareform(pdist([T1.N_Area;T2.N_Area]));
  raw_differences{t}.Area = area_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

  % MajorAxisLength differences
  MajorAxisLength_diff = squareform(pdist([T1.MajorAxisLength;T2.MajorAxisLength]));
  raw_differences{t}.MajorAxisLength = MajorAxisLength_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

  % MinorAxisLength differences
  MinorAxisLength_diff = squareform(pdist([T1.MinorAxisLength;T2.MinorAxisLength]));
  raw_differences{t}.MinorAxisLength = MinorAxisLength_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

  % Solidity differences
  Solidity_diff = squareform(pdist([T1.Solidity;T2.Solidity]));
  raw_differences{t}.Solidity = Solidity_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

  % Orientation differences
  Orientation_diff = squareform(pdist([T1.Orientation;T2.Orientation]));
  raw_differences{t}.Orientation = Orientation_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

  % Nuclear intensity differences
  nuc_intensity_diff = squareform(pdist([T1.N_Int3;T2.N_Int3]));
  raw_differences{t}.Nuc_intensity = nuc_intensity_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences
end

normalized_differences = {};
for t=1:length(raw_differences)
  normalized_differences{t}.Translation = normalize0to1(raw_differences{t}.Translation);
  normalized_differences{t}.Eccentricity = normalize0to1(raw_differences{t}.Eccentricity);
  normalized_differences{t}.Area = normalize0to1(raw_differences{t}.Area);
  normalized_differences{t}.MajorAxisLength = normalize0to1(raw_differences{t}.MajorAxisLength);
  normalized_differences{t}.MinorAxisLength = normalize0to1(raw_differences{t}.MinorAxisLength);
  normalized_differences{t}.Solidity = normalize0to1(raw_differences{t}.Solidity);
  normalized_differences{t}.Orientation = normalize0to1(raw_differences{t}.Orientation);
  normalized_differences{t}.Nuc_intensity = normalize0to1(raw_differences{t}.Nuc_intensity);
end

% Importance of each metric for when calculating composite distances
weights = {};
weights.Translation = 3;
weights.Eccentricity = 1;
weights.Area = 1;
weights.MajorAxisLength = 1;
weights.MinorAxisLength = 1;
weights.Solidity = 1;
weights.Orientation = 1;
weights.Nuc_intensity = 2;

composite_differences = {};
for t=1:length(normalized_differences)
  % composite_differences{t} = normalized_differences{t}.Translation .* weights.Translation;
  composite_differences{t} = normalized_differences{t}.Translation .* weights.Translation ...
                        + normalized_differences{t}.Eccentricity .* weights.Eccentricity ...
                        + normalized_differences{t}.Area .* weights.Area ...
                        + normalized_differences{t}.MajorAxisLength .* weights.MajorAxisLength ...
                        + normalized_differences{t}.MinorAxisLength .* weights.MinorAxisLength ...
                        + normalized_differences{t}.Solidity .* weights.Solidity ...
                        + normalized_differences{t}.Orientation .* weights.Orientation ...
                        + normalized_differences{t}.Nuc_intensity .* weights.Nuc_intensity;
end

%% FIND CELL TRACES
% Initialize all trace IDs to NaN
SubsetTable.TraceID = nan(height(SubsetTable),1);

% For the first frame, initialize trace IDs to to 1,2,3,etc.
SubsetTable.TraceID(1:sum(SubsetTable.Ti==1)) = 1:sum(SubsetTable.Ti==1);

%% CREATE TRACES BY FINDING CLOSEST MATCHING OBSERVATIONS BETWEEN T AND T+1
for timepoint=1:length(composite_differences)
  differences = composite_differences{timepoint};
  % Loop over difference matrix finding closest matches until no more matches can be made.
  % The intersection (m,n) in the differences matrix stores the difference/similarity between cell parent m and child n.
  while any(differences)
    [row column] = find(differences==min(differences(:))); % CLOSEST MATCH
    differences(row, column) = NaN; % IGNORE THIS MATCH ON NEXT LOOP
    parent_cell_id = column;
    child_cell_id = row;

    % Find parent trace ID
    T1 = SubsetTable.Ti==timepoint;
    idx = find(T1==1,parent_cell_id,'first');
    idx = idx(end);
    parent_trace_id = SubsetTable{idx,{'TraceID'}};

    % Set child trace ID to parent trace ID
    T2 = SubsetTable.Ti==timepoint+1;
    idx = find(T2==1,child_cell_id,'first');
    idx = idx(end);
    if isnan(SubsetTable{idx,{'TraceID'}})% the first time we set the TraceID is the best match
      SubsetTable.TraceID(idx) = parent_trace_id;
    end
  end
end

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

%% SAVE GIF TO DISK
date_str = datestr(now,'yyyymmddTHHMMSS');
filename = [date_str '.gif'];
for t=1:max(SubsetTable.Ti)
    if t==1;
      imwrite(labelled_nuc(:,:,t)./12,filename,'gif', 'DelayTime',0.5, 'Loopcount',inf);
    else
      imwrite(labelled_nuc(:,:,t)./12,filename,'gif', 'DelayTime',0.5, 'WriteMode','append');
    end
end

shortestpathtree(fully_connected_graph,end_nodes,start_nodes) % find all shortest paths from end points to start points
traces = T1Tracking(DiffMeasurementsTable)
% traces = AllCombinationsTracking(DiffMeasurementsTable)
Visualization1(traces)
folder_short = strrep(char(folder),'\','');
