function [global_cell_index] = find_index(ResultsTable, timepoint, traceUsed, cell_index_within_lost_Cells_Table)
  % Find the trace and global index for a cell in a ResultsTable at an index within a timepoint
  SubsetTable = ResultsTable.Time==timepoint & ResultsTable.TraceUsed==traceUsed;
  % Ugly matlab approach to getting the n'th element (ie. cell_index_within_timepoint) that is matching a search condition (ie. timepoint). Maybe there is a better way!!
  global_cell_index = find(SubsetTable==1,cell_index_within_lost_Cells_Table,'first');
  global_cell_index = global_cell_index(end);
end