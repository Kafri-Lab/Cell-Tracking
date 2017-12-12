function [global_cell_index] = find_index(ResultsTable, timepoint, traceUsed, cell_index_within_local_table, varargin)
  % Find the trace and global index for a cell in a ResultsTable at an index within a timepoint
  % use this function instead of "lookup_trace_id.m" for resegmented cells
  % as it has one more argument: "traceUsed"
  if length(varargin)==1
      SubsetTable = ResultsTable.Time==timepoint & ResultsTable.TraceUsed==traceUsed & strcmp(ResultsTable.Trace,varargin(1));
  else
      SubsetTable = ResultsTable.Time==timepoint & ResultsTable.TraceUsed==traceUsed;
  end
  global_cell_index = find(SubsetTable==1,cell_index_within_local_table,'first');
  global_cell_index = global_cell_index(end);
end