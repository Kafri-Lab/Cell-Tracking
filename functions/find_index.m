function [global_cell_index] = find_index(ResultsTable, timepoint, traceUsed, cell_index_within_local_table, varargin)
  % Find the trace and global index for a cell in a ResultsTable at an index within a timepoint
  if length(varargin)==1
      SubsetTable = ResultsTable.Time==timepoint & ResultsTable.TraceUsed==traceUsed & strcmp(ResultsTable.Trace,varargin(1));
  else
      SubsetTable = ResultsTable.Time==timepoint & ResultsTable.TraceUsed==traceUsed;
  end
  % Ugly matlab approach to getting the n'th element (ie. cell_index_within_timepoint) that is matching a search condition (ie. timepoint). Maybe there is a better way!!
  global_cell_index = find(SubsetTable==1,cell_index_within_local_table,'first');
  global_cell_index = global_cell_index(end);
end