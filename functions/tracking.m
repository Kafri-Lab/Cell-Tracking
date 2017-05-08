function CellsTable = cell_tracking_v1_simple(CellsTable, composite_differences)
  %% FIND CELL TRACES
  % Initialize all trace IDs to None
  CellsTable(:,{'Trace'}) = {'None'};
  % For the first frame initialize the cell traces to a random UUID
  CellsTable.Trace(1:sum(CellsTable.Ti==1)) = uuid_array(sum(CellsTable.Ti==1))';
  % CREATE TRACES BY FINDING CLOSEST MATCHING OBSERVATIONS BETWEEN T AND T+1
  for timepoint=1:length(composite_differences)
    differences = composite_differences{timepoint};
    % Loop over difference matrix finding closest matches until no more matches can be made.
    % The intersection (m,n) in the differences matrix stores the difference/similarity between former cell m and current cell n. Also see the longer description of the differences data structure above.
    while any(differences)
      [current_cell_index, former_cell_index] = find(differences==min(differences(:))); % MATCH

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
  end
end