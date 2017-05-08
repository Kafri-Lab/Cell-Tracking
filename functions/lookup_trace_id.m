function [trace global_cell_index] = find_trace(ResultsTable, timepoint, cell_index_within_timepoint)
  % Find the trace and global index for a cell in a ResultsTable at an index within a timepoint
  SubsetTable = ResultsTable.Ti==timepoint;
  global_cell_index = find(SubsetTable==1,cell_index_within_timepoint,'first');
  global_cell_index = global_cell_index(end);
  trace = ResultsTable{global_cell_index,{'Trace'}};
end
