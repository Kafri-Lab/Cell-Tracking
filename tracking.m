set(0,'DefaultFigureWindowStyle','docked')
addpath '\\carbon.research.sickkids.ca\rkafri\Miriam\Matlab function library'
addpath '\\carbon.research.sickkids.ca\rkafri\DanielS\cell_tracking\code\functions'

% Results table
%load('\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Processed OutPutFiles\Dataset_20170322_TG_Fibroblast_movie_2RESULTS\ResultTable.mat')

% Images path
folder = '\\carbon.research.sickkids.ca\rkafri\OPRETTA\Operetta Raw Data\Mammalian cells\20170322_TG_Fibroblast_movie_2__2017-03-22T17_52_56-Measurement1\Images\';


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


crop_amount=350;
nuc_cropped = nuc(1:crop_amount,1:crop_amount,:);
figure; imshow3D(nuc_cropped,[]);
rows = SubsetTable.Xcoord<crop_amount & SubsetTable.Ycoord<crop_amount;
CroppedTable = SubsetTable(rows,:);
SubsetTable_orig = SubsetTable;
SubsetTable = CroppedTable;

nuc_orig = nuc;
nuc = nuc_cropped;


% diff_measurements = DiffMeasurements(SubsetTable);

%% Calc Differetial Measurements between T and T+1
raw_differences = {};

%
% EXPLAINATION OF THE DIFFERENCES DATA STRUCTURE
%
% Example:
%
%    raw_differences =
%    
%      1×4 cell array
%    
%        [3×2 double]    [3×3 double]    [3×3 double]    [3×3 double]
%
% Example Explained:
%
%    raw_differences =
%    
%      1×4 cell array
%     
%      -In this example there are 5 timepoints, T1 to T5.
%      -Differences between timepoints are stored as a matrix in the cell array.
%      -The matrix size is large enough to compare all cells at timepoint T to all cells at T+1.
%      -Each value in the matrix contains the difference between one cell at timepoint T and one cell at T+1.
%      -Each cell at timepoint T is represented as a has a column in the matrix and each value 
%       in the cell's column is the observed difference to a cell at timepoint T+1.
%
%           T1-->T2        T2-->T3         T3-->T4         T4-->T5
%        [3×2 double]    [3×3 double]    [3×3 double]    [3×3 double]
%        /  \                            /  \
%       /   number of cells at T1       /   number of cells at T3
%    number of cells at T2           number of cells at T4

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
% Initialize all trace IDs to None
SubsetTable(:,{'Trace'}) = {'None'};
% For the first frame initialize the cell traces to a random UUID
SubsetTable.Trace(1:sum(SubsetTable.Ti==1)) = uuid_array(sum(SubsetTable.Ti==1))';
% CREATE TRACES BY FINDING CLOSEST MATCHING OBSERVATIONS BETWEEN T AND T+1
for timepoint=1:length(composite_differences)
  differences = composite_differences{timepoint};
  % Loop over difference matrix finding closest matches until no more matches can be made.
  % The intersection (m,n) in the differences matrix stores the difference/similarity between former cell m and current cell n. Also see the longer description of the differences data structure above.
  while any(differences)
    [row column] = find(differences==min(differences(:))); % CLOSEST MATCH
    former_cell_index = column;
    current_cell_index = row;
    differences(current_cell_index,former_cell_index) = NaN;
    % In the differences matrix, mark the whole column that corrosponds to the
    % former cell as NaN. This signifies that a match has been found for this
    % former cell.
    % differences(:,former_cell_index) = NaN;

    [former_trace former_cell_index_global] = find_trace(SubsetTable, timepoint, former_cell_index);
    [current_trace current_cell_index_global] = find_trace(SubsetTable, timepoint+1, current_cell_index);

    if strcmp(current_trace,'None') % only set the trace to the best/first match
      SubsetTable.Trace(current_cell_index_global) = former_trace
    end
  end
end

%% Overlay on nuc
labelled_nuc = nuc;
for t=1:max(SubsetTable.Ti)
  ObjectsInFrame = SubsetTable(SubsetTable.Ti==t,:);
  seed_mask_slice = zeros(size(nuc,1),size(nuc,2));
  for i=1:height(ObjectsInFrame)
    Object = ObjectsInFrame(i,:);
    x = floor(Object.Ycoord);
    y = floor(Object.Xcoord);
    trace = Object.Trace{:};
    TRACEID_DIPSLAY_LEN = 2;
    trace = trace(1:TRACEID_DIPSLAY_LEN);
    trace_id_im = text2im(trace);
    trace_id_im = imresize(trace_id_im ,1);
    labelled_nuc(x:x-1+size(trace_id_im,1),y:y-1+size(trace_id_im,2),t)=trace_id_im*max(nuc(:))*0.8; % overlay text
  end
end
figure; imshow3D(labelled_nuc,[]);




