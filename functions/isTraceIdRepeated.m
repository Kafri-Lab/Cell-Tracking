function isTraceIdRepeated(CellsTable,time_min, time_max) %use to debug 
    rows=CellsTable.Time>=time_min & CellsTable.Time<=time_max;
    CellsTable=CellsTable(rows,:);
    for t=time_min:time_max
        subset=CellsTable(CellsTable.Time==t,:);
        traces={};
        for i=1:height(subset)
            currentTrace=subset.Trace(i);
            for j=1:height(subset)
                if i~=j
                    trace=subset.Trace(j);
                    if strcmp(currentTrace, trace)==1 && ~size((find(strcmp(traces,trace))==0),1)
                        traces=[traces;trace];
                    end
                end
            end
        end
        sprintf('%d',t)
        traces
    end
end

% a(23,20)=a(12,12)
% for x=1:size(differences,1)
%     for y=1:size(differences,2)
%         R=differences==differences(x,y);
%         if sum(R(:)) > 1
%             sum(R(:))
%             differences(x,y)
%         end
%     end
% end
