function isTraceIdRepeated(CellsTable,time) %use to debug 
    rows=CellsTable.Time==time;
    CellsTable=CellsTable(rows,:);
    rows=rows(rows==1);
    for i=1:length(rows)-1
        currentTrace=CellsTable.Trace(i);
        for j=1:length(rows)
            if i~=j
                trace=CellsTable.Trace(j);
                if strcmp(currentTrace, trace)==1
                    error = 'Trace id repeated'
                end
            end

        end
    end
end
    