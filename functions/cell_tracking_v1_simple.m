function CellsTable = cell_tracking_v1_simple(CellsTable, composite_differences)
  %% FIND CELL TRACES
  % Initialize all trace IDs to None
  CellsTable(:,{'Trace'}) = {'None'};
  % For the first frame initialize the cell traces to a random UUID
  first_timepoint = 1:sum(CellsTable.Ti==1);
  CellsTable.Trace(first_timepoint) = uuid_array(sum(CellsTable.Ti==1))';
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

      [former_trace_id, former_cell_index_global] = lookup_trace_id(CellsTable, timepoint, former_cell_index);
      [current_trace_id, current_cell_index_global] = lookup_trace_id(CellsTable, timepoint+1, current_cell_index);

      if strcmp(current_trace_id,'None') % only set the trace to the best/first match. TODO: IS THIS REALLY NEEDED
        CellsTable.Trace(current_cell_index_global) = former_trace_id;
      end
    end
    % Give a trace ID to cells that were not matched (ie. new cells)
    cells_with_no_trace_id = CellsTable.Ti==timepoint+1 & strcmp(CellsTable.Trace,'None');
    CellsTable.Trace(cells_with_no_trace_id) = uuid_array(sum(cells_with_no_trace_id));
  end

end