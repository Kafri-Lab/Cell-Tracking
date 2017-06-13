function [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(SubsetTable)
  %% Calc Differetial Measurements between T and T+1 
  % 
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
  %      -In this example there are 5 timepoints, T1 to T5, there are four differeneces and thus four items in the cell array.
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

  %% RAW DIFFERENCES
  raw_differences = {};

  count = 1; % this is needed because "t" in the loop may not start at 1, we could
  % if we really wanted to start processing timepoints in the middle of the sequence
  for t=min(SubsetTable.Time):max(SubsetTable.Time)-1
    % Get only cells (ie. table rows) at T and T+1
    T1 = SubsetTable(SubsetTable.Time==t,:);
    T2 = SubsetTable(SubsetTable.Time==t+1,:);
   
    % Tranlation distances between T and T+1
    X_translation = squareform(pdist([T1.Centroid(:,1);T2.Centroid(:,1)]));
    X_translation=X_translation(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing translation
    Y_translation = squareform(pdist([T1.Centroid(:,2);T2.Centroid(:,2)]));
    Y_translation=Y_translation(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing translation
    [theta,rho] = cart2pol(X_translation,Y_translation);
    raw_differences{count}.Translation = rho;

    % Eccentricity differences
    eccentricity_diff = squareform(pdist([T1.Eccentricity;T2.Eccentricity]));
    raw_differences{count}.Eccentricity = eccentricity_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    % Nuclear area differences
    area_diff = squareform(pdist([T1.NArea;T2.NArea]));
    raw_differences{count}.Area = area_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    % MajorAxisLength differences
    MajorAxisLength_diff = squareform(pdist([T1.MajorAxisLength;T2.MajorAxisLength]));
    raw_differences{count}.MajorAxisLength = MajorAxisLength_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    % MinorAxisLength differences
    MinorAxisLength_diff = squareform(pdist([T1.MinorAxisLength;T2.MinorAxisLength]));
    raw_differences{count}.MinorAxisLength = MinorAxisLength_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    % Solidity differences
    Solidity_diff = squareform(pdist([T1.Solidity;T2.Solidity]));
    raw_differences{count}.Solidity = Solidity_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    % Orientation differences
    Orientation_diff = squareform(pdist([T1.Orientation;T2.Orientation]));
    raw_differences{count}.Orientation = Orientation_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    % Nuclear intensity differences
    nuc_intensity_diff = squareform(pdist([T1.NInt;T2.NInt]));
    raw_differences{count}.Nuc_intensity = nuc_intensity_diff(height(T1)+1:end,1:height(T1)); % produces matrix of size lenT1 x lenT2 containing differences

    count = count+1;
  end

  %% NORMALIZED DIFFERENCES
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
  weights.Translation = 4;
  weights.Eccentricity = 1;
  weights.Area = 1;
  weights.MajorAxisLength = 1;
  weights.MinorAxisLength = 1;
  weights.Solidity = 1;
  weights.Orientation = 1;
  weights.Nuc_intensity = 2;

  %% COMPOSITE DIFFERENCES
  composite_differences = {};
  for t=1:length(normalized_differences)
    % composite_differences{t} = normalized_differences{t}.Translation .* weights.Translation;
    composite_differences{t} = normalized_differences{t}.Translation .* weights.Translation ...
                          + normalized_differences{t}.Eccentricity .* weights.Eccentricity ...
                          + normalized_differences{t}.Area .* weights.Area ...
                          + normalized_differences{t}.MajorAxisLength .* weights.MajorAxisLength ...
                          + normalized_differences{t}.MinorAxisLength .* weights.MinorAxisLength ...
                          + normalized_differences{t}.Solidity .* weights.Solidity ...
                          + normalized_differences{t}.Orientation .* weights.Orientation;
                          + normalized_differences{t}.Nuc_intensity .* weights.Nuc_intensity;
  end
end