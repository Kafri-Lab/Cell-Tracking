function [CellsTable] = cell_tracking_v1_simple(CellsTable, composite_differences)
  %% FIND CELL TRACES
  % Initialize all trace IDs to None
  diffTable=table(0,0,{''}); % used to aid debugging
  CellsTable(:,{'Trace'}) = {'None'};
  % For the first frame (ie. min(CellsTable.Time) initialize the cell traces to a random UUID
  first_timepoint_cells = 1:sum(CellsTable.Time==min(CellsTable.Time));
  CellsTable.Trace(first_timepoint_cells) = uuid_array(sum(CellsTable.Time==min(CellsTable.Time)))';
  % CREATE TRACES BY FINDING CLOSEST MATCHING OBSERVATIONS FIRST BETWEEN T AND T+1
  for timepoint=1:19%length(composite_differences)
    previous_timepoint = timepoint+min(CellsTable.Time)-1;
    current_timepoint = timepoint+min(CellsTable.Time);
    differences = composite_differences{timepoint};
    % Loop over difference matrix finding closest matches until no more matches can be made.
    % The intersection (m,n) in the differences matrix stores the difference/similarity between former cell m and current cell n. Also see the longer description of the differences data structure above.
    while any(differences(:))
      
      %%
      % Find pair that is least different
      [current_cell_index, former_cell_index] = find(differences==min(differences(:))); % MATCH FOUND

      % TODO: Handle multiple exact matches found
      mindiff=min(differences(:));
      % In the differences matrix, mark the whole column that corrosponds to the
      % former cell as NaN. This signifies that a match has been found for this
      % former cell. Also, mark the whole row that corresponds to the
      % current cell as NaN. This signifies that a match has been found for
      % this current cell.
      differences(:,former_cell_index) = NaN;
      differences(current_cell_index,:) = NaN;

      % Find ID in results table using ID in differences matrix
      [former_trace_id, former_cell_index_global] = lookup_trace_id(CellsTable, previous_timepoint, former_cell_index);
      [current_trace_id, current_cell_index_global] = lookup_trace_id(CellsTable, current_timepoint, current_cell_index);
      newRow = {previous_timepoint,mindiff,former_trace_id}; % used to aid debugging
      diffTable=[diffTable;newRow]; % used to aid debugging

      if strcmp(current_trace_id,'None') % only set the trace to the best/first match. TODO: IS THIS REALLY NEEDED
        CellsTable.Trace(current_cell_index_global) = former_trace_id;
        CellsTable.TraceUsed(former_cell_index_global) = 1;
      end
      
      mindiff
      former_trace_id
      former_cell_index_global
      current_trace_id
      current_cell_index_global
      
    end

    %% MITOSIS CELLS
    % Find born cells that have a high mitosis probability in the current timepoint and have not been assigned a trace id
    newborns_cells = find(CellsTable.SaddlePoint > 50 & CellsTable.Time==current_timepoint & strcmp(CellsTable.Trace,'None'));
    %Check if there are any newborn cells. If not, continue to next
    %iteration.
    % Find possible parent cells
        mitosis_cells = CellsTable.SaddlePoint > 50;
        previous_timepoint_cells = CellsTable.Time==previous_timepoint;
        %need to ensure that a possible parent's trace id has not yet been used
        %to label a current cell
        traceUsed = CellsTable.TraceUsed==0;
        PossibleParents = CellsTable(find(mitosis_cells & previous_timepoint_cells & traceUsed),:);
        % Find closest parent to newboard distance
        % TODO: Using more metrics than distance
        PossibleParentsUpdated = PossibleParents;
        if isempty(PossibleParents)~=1
            for i=1:length(newborns_cells)
              possible_newborn = CellsTable(newborns_cells(i),:);
              neighbour_distances = sqrt(abs(PossibleParentsUpdated.Centroid(:,1)-possible_newborn.Centroid(:,1)).^2 + abs(PossibleParentsUpdated.Centroid(:,2)-possible_newborn.Centroid(:,2)).^2); %euclidean distance
              closest_neighbour_id = find(min(neighbour_distances));
              ParentCell = PossibleParentsUpdated(closest_neighbour_id,:);
              PossibleParentsUpdated((closest_neighbour_id),:)=[]; %removes row pertaining to the parent cell so that it is only matched with one newborn cell
              CellsTable.Trace(newborns_cells(i)) = ParentCell.Trace;
              ParentCell.TraceUsed=1;
            end
        end
    %% CELLS ENTERING FRAME
    % Give a trace ID to cells that were not matched
    cells_entering_frame = CellsTable.Time==current_timepoint & strcmp(CellsTable.Trace,'None');
    CellsTable.Trace(cells_entering_frame) = uuid_array(sum(cells_entering_frame));
  end
  
  diffTable % used to aid debugging

end