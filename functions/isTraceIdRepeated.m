function isTraceIdRepeated(CellsTable,time) %use to debug 
    rows=CellsTable.Time==time;
    CellsTable=CellsTable(rows,:);
    rows=rows(rows==1);
    traces={};
    for i=1:size(rows,1)
        currentTrace=CellsTable.Trace(i);
        for j=1:size(rows,1)
            if i~=j
                trace=CellsTable.Trace(j);
                if strcmp(currentTrace, trace)==1 && ~size((find(strcmp(traces,trace))==0),1)
                    traces=[traces;trace];
                end
            end
        end
    end
    traces
end

% a(23,20)=a(12,12)
% for x=1:size(a,1)
%     for y=1:size(a,2)
%         R=a==a(x,y);
%         if sum(R(:)) > 1
%             sum(R(:))
%             a(x,y)
%         end
%     end
% end

