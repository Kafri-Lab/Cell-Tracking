function CellsTable = cell_tracking_v1_simple(CellsTable, composite_differences)
  %% FIND CELL TRACES
  % Initialize all trace IDs to None
  CellsTable(:,{'Trace'}) = {'None'};
  % For the first frame (ie. min(CellsTable.Ti) initialize the cell traces to a random UUID
  first_timepoint_cells = 1:sum(CellsTable.Ti==min(CellsTable.Ti));
  CellsTable.Trace(first_timepoint_cells) = uuid_array(sum(CellsTable.Ti==min(CellsTable.Ti)))';
  % CREATE TRACES BY FINDING CLOSEST MATCHING OBSERVATIONS BETWEEN T AND T+1
  for timepoint=1:length(composite_differences)
    differences = composite_differences{timepoint};
    % Loop over difference matrix finding closest matches until no more matches can be made.
    % The intersection (m,n) in the differences matrix stores the difference/similarity between former cell m and current cell n. Also see the longer description of the differences data structure above.
    while any(differences(:))
      % Find pair that is least different
      [current_cell_index, former_cell_index] = find(differences==min(differences(:))); % MATCH FOUND

      % In the differences matrix, mark the whole column that corrosponds to the
      % former cell as NaN. This signifies that a match has been found for this
      % former cell.
      differences(:,former_cell_index) = NaN;

      % Find ID in results table using ID in differences matrix
      [former_trace_id, former_cell_index_global] = lookup_trace_id(CellsTable, timepoint+min(CellsTable.Ti)-1, former_cell_index);
      [current_trace_id, current_cell_index_global] = lookup_trace_id(CellsTable, timepoint+min(CellsTable.Ti), current_cell_index);

      if strcmp(current_trace_id,'None') % only set the trace to the best/first match. TODO: IS THIS REALLY NEEDED
        CellsTable.Trace(current_cell_index_global) = former_trace_id;
      end
    end

    %% MITOSIS CELLS
    newborns_cells = find(CellsTable.Mitosis > 0.5 & CellsTable.Ti==timepoint+min(CellsTable.Ti) & strcmp(CellsTable.Trace,'None'));
    % Find possible parent cells
    mitosis_cells = CellsTable.Mitosis > 0.5;
    timepoint_cells = CellsTable.Ti==timepoint+min(CellsTable.Ti)-1;
    PossibleParents = CellsTable(find(mitosis_cells & timepoint_cells),:);
    for i=1:length(newborns_cells)
      possible_newborn = CellsTable(newborns_cells(i),:);
      neighbour_distances = abs(PossibleParents.Xcoord-possible_newborn.Xcoord) + abs(PossibleParents.Ycoord-possible_newborn.Ycoord);
      ParentCell = PossibleParents(find(min(neighbour_distances)),:);
      CellsTable.Trace(newborns_cells(i)) = ParentCell.Trace;
    end

    %% CELLS ENTERING FRAME
    % Give a trace ID to cells that were not matched
    cells_entering_frame = CellsTable.Ti==timepoint+min(CellsTable.Ti) & strcmp(CellsTable.Trace,'None');
    CellsTable.Trace(cells_entering_frame) = uuid_array(sum(cells_entering_frame));
  end

end